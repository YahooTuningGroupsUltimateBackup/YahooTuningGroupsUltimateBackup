// Shared between the Node server/CLI (CommonJS) and the static browser search
// page (script tag → window.ytgubQuerySql), so both run the identical query.
(function (root, factory) {
    if (typeof module === 'object' && module.exports) module.exports = factory()
    else root.ytgubQuerySql = factory()
})(typeof self !== 'undefined' ? self : this, function () {
    const SUBJECT_WEIGHT = 4
    const AUTHOR_WEIGHT = 2
    const BODY_WEIGHT = 1

    const MATCH_PARAMETER = '?1'

    const quoteEachTerm = query => query
        .split(/\s+/)
        .map(term => term.replace(/"/g, ''))
        .filter(Boolean)
        .map(term => `"${term}"`)
        .join(' ')

    // Ranked in a subquery that carries nothing but a rowid and a score, so the
    // sorter it fills holds two numbers per match instead of a whole message.
    // Only the handful of rows that survive the LIMIT are joined back for their
    // columns and their snippet — a common word matches 60,000 messages, and
    // fetching every one of those rows (each carrying its body) to throw all but
    // twenty away is what made a search take tens of seconds. Parameters are
    // numbered rather than positional because the match expression is bound
    // twice: once to rank, once to snippet.
    //
    // Those last two joins are CROSS so that the ranked rows drive them. Both
    // match on a rowid and there are at most `limit` of them, so leading with
    // them is always right — but the SQLite inside the browser's WASM engine is
    // 3.35, which reads this as a plain join, scans the whole match set a second
    // time, and fetches all 60,000 messages after all. The inner join is left
    // free to reorder: a filter that names a single topic really is better
    // driven from the messages table.
    const buildSearchSql = ({lists, topicId, author, after, before}) => {
        const filterConditions = []
        const parameters = []
        // Offset by one: MATCH_PARAMETER holds the first slot, filters follow it.
        const bind = value => {
            parameters.push(value)
            return `?${parameters.length + 1}`
        }

        if (lists && lists.length) {
            filterConditions.push(`f.list IN (${lists.map(list => bind(list)).join(', ')})`)
        }
        if (topicId !== undefined) {
            filterConditions.push(`f.topic_id = ${bind(topicId)}`)
        }
        if (author) {
            filterConditions.push(`f.author LIKE ${bind(`%${author}%`)}`)
        }
        if (after !== undefined) {
            filterConditions.push(`f.post_date >= ${bind(after)}`)
        }
        if (before !== undefined) {
            filterConditions.push(`f.post_date < ${bind(before)}`)
        }

        // Joined only when something needs filtering; the messages_filter index
        // covers every column the filters can name, so this never reads a row.
        const filterJoin = filterConditions.length ? 'JOIN messages f ON f.id = messages_fts.rowid' : ''
        const limitParameter = `?${parameters.length + 2}`

        const sql = `
            SELECT
                m.list AS list,
                m.msg_id AS msgId,
                m.topic_id AS topicId,
                m.post_date AS postDate,
                m.author AS author,
                m.subject AS subject,
                snippet(messages_fts, 2, '[', ']', ' … ', 12) AS snippet,
                ranked.rank AS rank
            FROM (
                SELECT
                    messages_fts.rowid AS id,
                    bm25(messages_fts, ${SUBJECT_WEIGHT}, ${AUTHOR_WEIGHT}, ${BODY_WEIGHT}) AS rank
                FROM messages_fts ${filterJoin}
                WHERE ${[`messages_fts MATCH ${MATCH_PARAMETER}`, ...filterConditions].join(' AND ')}
                ORDER BY rank
                LIMIT ${limitParameter}
            ) AS ranked
            CROSS JOIN messages_fts ON messages_fts.rowid = ranked.id AND messages_fts MATCH ${MATCH_PARAMETER}
            CROSS JOIN messages m ON m.id = ranked.id
            ORDER BY ranked.rank
        `
        return {sql, parameters}
    }

    const TOPIC_NAME_SQL =
        'SELECT subject FROM messages WHERE list = ? AND topic_id = ? ORDER BY msg_id LIMIT 1'

    return {buildSearchSql, quoteEachTerm, TOPIC_NAME_SQL}
})
