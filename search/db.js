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
    -- Covers the rowid plus every column a search filter can name, so testing a
    -- filter reads only this index and never a messages row (each of which
    -- carries a whole message body).
    CREATE INDEX IF NOT EXISTS messages_filter ON messages(id, list, topic_id, post_date, author);
    -- Seeks straight to a topic's earliest message for the topic-scoped search
    -- bar; the UNIQUE(list, msg_id) index can only narrow that to a whole list.
    CREATE INDEX IF NOT EXISTS messages_topic ON messages(list, topic_id, msg_id);
`

// The planner picks the join order for a filtered search from these statistics.
// Without them it drives the search from the messages table and probes the
// full-text index once per message, which takes tens of seconds against the real
// archive; with them it drives from the full-text index, which takes tens of
// milliseconds. Never run on an empty table — the "one row" statistics that
// would record are worse than none.
const analyze = db => {
    if (db.prepare('SELECT id FROM messages LIMIT 1').get()) db.exec('ANALYZE')
}

const hasStatistics = db =>
    Boolean(db.prepare("SELECT name FROM sqlite_master WHERE name = 'sqlite_stat1'").get())

const openIndex = path => {
    const db = new DatabaseSync(path)
    db.exec('PRAGMA journal_mode = WAL')
    db.exec('PRAGMA synchronous = NORMAL')
    db.exec(SCHEMA)
    // An index built before the statistics existed heals itself on first open.
    if (!hasStatistics(db)) analyze(db)

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

    return {addDocs, search, lists, topicName, analyze: () => analyze(db), close: () => db.close()}
}

module.exports = {openIndex, analyze}
