const {test} = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const os = require('node:os')
const path = require('node:path')
const {DatabaseSync} = require('node:sqlite')
const {openIndex} = require('../search/db')

const doc = overrides => ({
    list: 'tuning',
    msgId: 1,
    topicId: 10,
    postDate: 1000000000,
    author: 'Paul Erlich',
    subject: 'porcupine temperament',
    body: 'The porcupine comma vanishes.',
    ...overrides,
})

test('indexed docs are found by full-text match with metadata and snippet returned', () => {
    const index = openIndex(':memory:')
    index.addDocs([
        doc({}),
        doc({msgId: 2, topicId: 11, author: 'Dave Keenan', subject: 'meantone', body: 'Nothing about spiny rodents here.'}),
    ])

    const results = index.search('porcupine')

    assert.equal(results.length, 1)
    const r = results[0]
    assert.equal(r.msgId, 1)
    assert.equal(r.list, 'tuning')
    assert.equal(r.topicId, 10)
    assert.equal(r.author, 'Paul Erlich')
    assert.equal(r.subject, 'porcupine temperament')
    assert.equal(r.postDate, 1000000000)
    assert.match(r.snippet, /\[porcupine\]/)
})

test('search supports list, author, and date filters plus a result limit', () => {
    const index = openIndex(':memory:')
    index.addDocs([
        doc({msgId: 1, list: 'tuning', author: 'Paul Erlich', postDate: 100}),
        doc({msgId: 2, list: 'tuning-math', author: 'Paul Erlich', postDate: 200}),
        doc({msgId: 3, list: 'tuning-math', author: 'Dave Keenan', postDate: 300}),
        doc({msgId: 4, list: 'metatuning', author: 'Dave Keenan', postDate: 400}),
    ])

    const byList = index.search('porcupine', {lists: ['tuning-math', 'metatuning']})
    assert.deepEqual(byList.map(r => r.msgId).sort(), [2, 3, 4])

    const byAuthor = index.search('porcupine', {author: 'keenan'})
    assert.deepEqual(byAuthor.map(r => r.msgId).sort(), [3, 4])

    const byDate = index.search('porcupine', {after: 200, before: 400})
    assert.deepEqual(byDate.map(r => r.msgId).sort(), [2, 3])

    const limited = index.search('porcupine', {limit: 2})
    assert.equal(limited.length, 2)
})

test('search accepts FTS5 operator syntax but survives queries that are not valid FTS5', () => {
    const index = openIndex(':memory:')
    index.addDocs([
        doc({msgId: 1, subject: 'porcupine', body: 'spiny'}),
        doc({msgId: 2, subject: 'meantone', body: 'smooth'}),
        doc({msgId: 3, subject: 'miracle', body: 'blackjack scale 10/9'}),
    ])

    const operators = index.search('porcupine OR meantone')
    assert.deepEqual(operators.map(r => r.msgId).sort(), [1, 2])

    const unbalancedQuote = index.search('"blackjack')
    assert.deepEqual(unbalancedQuote.map(r => r.msgId), [3])

    const ratio = index.search('10/9')
    assert.deepEqual(ratio.map(r => r.msgId), [3])

    assert.deepEqual(index.search('   '), [])
})

test('search can be scoped to a single topic', () => {
    const index = openIndex(':memory:')
    index.addDocs([
        doc({msgId: 1, topicId: 5, list: 'tuning'}),
        doc({msgId: 2, topicId: 6, list: 'tuning'}),
        doc({msgId: 3, topicId: 5, list: 'tuning-math'}),
    ])

    const results = index.search('porcupine', {lists: ['tuning'], topicId: 5})

    assert.deepEqual(results.map(r => r.msgId), [1])
})

test('addDocs keeps the first copy of a list+msgId and reports how many docs it actually inserted', () => {
    const index = openIndex(':memory:')

    const inserted = index.addDocs([
        doc({msgId: 1, subject: 'first copy'}),
        doc({msgId: 1, subject: 'second copy'}),
        doc({msgId: 1, list: 'tuning-math', subject: 'other list copy'}),
    ])

    assert.equal(inserted, 2)
    const results = index.search('copy')
    assert.deepEqual(results.map(r => r.subject).sort(), ['first copy', 'other list copy'])
})

test('lists returns the distinct indexed list names in alphabetical order', () => {
    const index = openIndex(':memory:')
    index.addDocs([
        doc({msgId: 1, list: 'tuning'}),
        doc({msgId: 2, list: 'metatuning'}),
        doc({msgId: 3, list: 'tuning'}),
    ])

    assert.deepEqual(index.lists(), ['metatuning', 'tuning'])
})

// Both indexes and the statistics exist to keep a filtered search off the
// messages table, whose rows carry the message bodies. Missing either one, the
// planner drives a list-scoped search from that table and probes the full-text
// index once per message: tens of seconds against the real archive, and worse
// in the browser, where every page read is an HTTP range request.
test('an opened index carries the covering filter index and the topic index', t => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ytgub-indexes-'))
    t.after(() => fs.rmSync(tmpDir, {recursive: true, force: true}))
    const dbPath = path.join(tmpDir, 'index.db')

    openIndex(dbPath).close()

    const db = new DatabaseSync(dbPath)
    try {
        const indexes = Object.fromEntries(
            db.prepare("SELECT name, sql FROM sqlite_master WHERE type = 'index' AND sql IS NOT NULL")
                .all().map(row => [row.name, row.sql]),
        )
        assert.match(indexes.messages_filter, /messages\(id, list, topic_id, post_date, author\)/)
        assert.match(indexes.messages_topic, /messages\(list, topic_id, msg_id\)/)
    } finally {
        db.close()
    }
})

test('statistics are recorded once there are messages to describe, and never before', t => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ytgub-stats-'))
    t.after(() => fs.rmSync(tmpDir, {recursive: true, force: true}))
    const dbPath = path.join(tmpDir, 'index.db')

    const statisticsOf = () => {
        const db = new DatabaseSync(dbPath)
        try {
            const present = db.prepare("SELECT name FROM sqlite_master WHERE name = 'sqlite_stat1'").get()
            return present ? db.prepare('SELECT tbl, idx FROM sqlite_stat1').all().map(row => row.idx || row.tbl) : null
        } finally {
            db.close()
        }
    }

    // An empty index gets none: "one row" statistics would mislead the planner
    // worse than no statistics at all.
    const empty = openIndex(dbPath)
    assert.equal(statisticsOf(), null)

    empty.addDocs([doc({}), doc({msgId: 2, topicId: 11})])
    empty.analyze()
    empty.close()

    const analyzed = statisticsOf()
    assert.ok(analyzed.includes('messages_filter'), `no statistics for messages_filter in ${analyzed}`)
    assert.ok(analyzed.includes('messages_topic'), `no statistics for messages_topic in ${analyzed}`)
})

test('an index built before the statistics existed records them on the next open', t => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ytgub-heal-'))
    t.after(() => fs.rmSync(tmpDir, {recursive: true, force: true}))
    const dbPath = path.join(tmpDir, 'index.db')

    const stale = openIndex(dbPath)
    stale.addDocs([doc({})])
    stale.close()

    const hasStatistics = () => {
        const db = new DatabaseSync(dbPath)
        try {
            return Boolean(db.prepare("SELECT name FROM sqlite_master WHERE name = 'sqlite_stat1'").get())
        } finally {
            db.close()
        }
    }
    assert.equal(hasStatistics(), false)

    openIndex(dbPath).close()
    assert.equal(hasStatistics(), true)
})

test('topicName returns the subject of the earliest message in a list topic', () => {
    const index = openIndex(':memory:')
    index.addDocs([
        doc({msgId: 9, topicId: 5, subject: 'Re: porcupine pumps'}),
        doc({msgId: 3, topicId: 5, subject: 'porcupine pumps'}),
        doc({msgId: 1, topicId: 5, list: 'tuning-math', subject: 'same id, other list'}),
    ])

    assert.equal(index.topicName('tuning', 5), 'porcupine pumps')
    assert.equal(index.topicName('tuning', 999), null)
})
