const {test} = require('node:test')
const assert = require('node:assert/strict')
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
