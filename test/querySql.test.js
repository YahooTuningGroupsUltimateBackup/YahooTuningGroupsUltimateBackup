const {test} = require('node:test')
const assert = require('node:assert/strict')
const {buildSearchSql, quoteEachTerm} = require('../search/querySql')

test('buildSearchSql produces the ranked FTS query with filter conditions and bound parameters', () => {
    const bare = buildSearchSql({})
    assert.match(bare.sql, /messages_fts MATCH \?/)
    assert.match(bare.sql, /snippet\(messages_fts, 2/)
    assert.match(bare.sql, /bm25\(messages_fts, 4, 2, 1\)/)
    assert.match(bare.sql, /ORDER BY rank/)
    assert.match(bare.sql, /LIMIT \?/)
    assert.deepEqual(bare.parameters, [])

    const filtered = buildSearchSql({
        lists: ['tuning', 'tuning-math'],
        topicId: 5,
        author: 'erlich',
        after: 100,
        before: 200,
    })
    assert.match(filtered.sql, /m\.list IN \(\?, \?\)/)
    assert.match(filtered.sql, /m\.topic_id = \?/)
    assert.match(filtered.sql, /m\.author LIKE \?/)
    assert.match(filtered.sql, /m\.post_date >= \?/)
    assert.match(filtered.sql, /m\.post_date < \?/)
    assert.deepEqual(filtered.parameters, ['tuning', 'tuning-math', 5, '%erlich%', 100, 200])
})

test('quoteEachTerm turns free text into a safe FTS phrase-per-word query', () => {
    assert.equal(quoteEachTerm('porcupine  "unbalanced'), '"porcupine" "unbalanced"')
    assert.equal(quoteEachTerm('  '), '')
})
