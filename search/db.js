const {DatabaseSync} = require('node:sqlite')

const SCHEMA = `
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY,
        list TEXT NOT NULL,
        msg_id INTEGER NOT NULL,
        topic_id INTEGER,
        post_date INTEGER,
        author TEXT,
        subject TEXT,
        body TEXT,
        UNIQUE (list, msg_id)
    );
    CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
        subject, author, body,
        content='messages', content_rowid='id',
        tokenize='porter unicode61'
    );
`

const SUBJECT_WEIGHT = 4.0
const AUTHOR_WEIGHT = 2.0
const BODY_WEIGHT = 1.0

const quoteEachTerm = query => query
    .split(/\s+/)
    .map(term => term.replace(/"/g, ''))
    .filter(Boolean)
    .map(term => `"${term}"`)
    .join(' ')

const openIndex = path => {
    const db = new DatabaseSync(path)
    db.exec('PRAGMA journal_mode = WAL')
    db.exec('PRAGMA synchronous = NORMAL')
    db.exec(SCHEMA)

    // OR IGNORE: the exports re-fetched some messages, so the same list+msgId can
    // appear in two files; the first copy indexed wins.
    const insertMessage = db.prepare(`
        INSERT OR IGNORE INTO messages (list, msg_id, topic_id, post_date, author, subject, body)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `)
    const insertFts = db.prepare(`
        INSERT INTO messages_fts (rowid, subject, author, body)
        VALUES (?, ?, ?, ?)
    `)

    const addDocs = docs => {
        let inserted = 0
        db.exec('BEGIN')
        try {
            docs.forEach(({list, msgId, topicId, postDate, author, subject, body}) => {
                const {changes, lastInsertRowid} = insertMessage.run(list, msgId, topicId, postDate, author, subject, body)
                if (!changes) return
                insertFts.run(lastInsertRowid, subject, author, body)
                inserted += 1
            })
            db.exec('COMMIT')
        } catch (error) {
            db.exec('ROLLBACK')
            throw error
        }
        return inserted
    }

    const search = (query, {lists, author, after, before, limit = 20, topicId} = {}) => {
        const filterConditions = []
        const filterParameters = []

        if (lists && lists.length) {
            filterConditions.push(`m.list IN (${lists.map(() => '?').join(', ')})`)
            filterParameters.push(...lists)
        }
        if (topicId !== undefined) {
            filterConditions.push('m.topic_id = ?')
            filterParameters.push(topicId)
        }
        if (author) {
            filterConditions.push('m.author LIKE ?')
            filterParameters.push(`%${author}%`)
        }
        if (after !== undefined) {
            filterConditions.push('m.post_date >= ?')
            filterParameters.push(after)
        }
        if (before !== undefined) {
            filterConditions.push('m.post_date < ?')
            filterParameters.push(before)
        }

        const statement = db.prepare(`
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
        `)
        const attempt = matchExpression => statement.all(matchExpression, ...filterParameters, limit)

        try {
            return attempt(query)
        } catch (error) {
            const sanitized = quoteEachTerm(query)
            if (!sanitized) return []
            return attempt(sanitized)
        }
    }

    const lists = () =>
        db.prepare('SELECT DISTINCT list FROM messages ORDER BY list').all().map(row => row.list)

    return {addDocs, search, lists, close: () => db.close()}
}

module.exports = {openIndex}
