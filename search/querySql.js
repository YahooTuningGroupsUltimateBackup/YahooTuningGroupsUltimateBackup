// Shared between the Node server/CLI (CommonJS) and the static browser search
// page (script tag → window.ytgubQuerySql), so both run the identical query.
(function (root, factory) {
    if (typeof module === 'object' && module.exports) module.exports = factory()
    else root.ytgubQuerySql = factory()
})(typeof self !== 'undefined' ? self : this, function () {
    const SUBJECT_WEIGHT = 4
    const AUTHOR_WEIGHT = 2
    const BODY_WEIGHT = 1

    const quoteEachTerm = query => query
        .split(/\s+/)
        .map(term => term.replace(/"/g, ''))
        .filter(Boolean)
        .map(term => `"${term}"`)
        .join(' ')

    const buildSearchSql = ({lists, topicId, author, after, before}) => {
        const filterConditions = []
        const parameters = []

        if (lists && lists.length) {
            filterConditions.push(`m.list IN (${lists.map(() => '?').join(', ')})`)
            parameters.push(...lists)
        }
        if (topicId !== undefined) {
            filterConditions.push('m.topic_id = ?')
            parameters.push(topicId)
        }
        if (author) {
            filterConditions.push('m.author LIKE ?')
            parameters.push(`%${author}%`)
        }
        if (after !== undefined) {
            filterConditions.push('m.post_date >= ?')
            parameters.push(after)
        }
        if (before !== undefined) {
            filterConditions.push('m.post_date < ?')
            parameters.push(before)
        }

        const sql = `
            SELECT
                m.list AS list,
                m.msg_id AS msgId,
                m.topic_id AS topicId,
                m.post_date AS postDate,
                m.author AS author,
                m.subject AS subject,
                snippet(messages_fts, 2, '[', ']', ' … ', 12) AS snippet,
                bm25(messages_fts, ${SUBJECT_WEIGHT}, ${AUTHOR_WEIGHT}, ${BODY_WEIGHT}) AS rank
            FROM messages_fts
            JOIN messages m ON m.id = messages_fts.rowid
            WHERE ${['messages_fts MATCH ?', ...filterConditions].join(' AND ')}
            ORDER BY rank
            LIMIT ?
        `
        return {sql, parameters}
    }

    const TOPIC_NAME_SQL =
        'SELECT subject FROM messages WHERE list = ? AND topic_id = ? ORDER BY msg_id LIMIT 1'

    return {buildSearchSql, quoteEachTerm, TOPIC_NAME_SQL}
})
