const {DatabaseSync} = require('node:sqlite')
const {buildSearchSql, quoteEachTerm, TOPIC_NAME_SQL} = require('./querySql')

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
        const {sql, parameters} = buildSearchSql({lists, topicId, author, after, before})
        const statement = db.prepare(sql)
        const attempt = matchExpression => statement.all(matchExpression, ...parameters, limit)

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

    const topicName = (list, topicId) => {
        const row = db.prepare(TOPIC_NAME_SQL).get(list, topicId)
        return row ? row.subject : null
    }

    return {addDocs, search, lists, topicName, close: () => db.close()}
}

module.exports = {openIndex}
