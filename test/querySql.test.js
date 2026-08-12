const {test} = require('node:test')
const assert = require('node:assert/strict')
const {buildSearchSql, quoteEachTerm} = require('../search/querySql')

test('buildSearchSql produces the ranked FTS query with filter conditions and bound parameters', () => {
    const bare = buildSearchSql({})
    assert.match(bare.sql, /messages_fts MATCH \?1/)
    assert.match(bare.sql, /snippet\(messages_fts, 2/)
    assert.match(bare.sql, /bm25\(messages_fts, 4, 2, 1\)/)
    assert.match(bare.sql, /ORDER BY rank/)
    assert.match(bare.sql, /LIMIT \?2/)
    assert.deepEqual(bare.parameters, [])

    const filtered = buildSearchSql({
        lists: ['tuning', 'tuning-math'],
        topicId: 5,
        author: 'erlich',
        after: 100,
        before: 200,
    })
    assert.match(filtered.sql, /f\.list IN \(\?2, \?3\)/)
    assert.match(filtered.sql, /f\.topic_id = \?4/)
    assert.match(filtered.sql, /f\.author LIKE \?5/)
    assert.match(filtered.sql, /f\.post_date >= \?6/)
    assert.match(filtered.sql, /f\.post_date < \?7/)
    assert.match(filtered.sql, /LIMIT \?8/)
    assert.deepEqual(filtered.parameters, ['tuning', 'tuning-math', 5, '%erlich%', 100, 200])
})

// A match on a common word covers tens of thousands of messages. Everything the
// LIMIT is going to discard has to stay cheap, so the ranking subquery selects
// only a rowid and a score, and the message row and its snippet are fetched
// outside it — for the survivors alone.
test('buildSearchSql ranks on rowids alone and reads message rows only outside that subquery', () => {
    const {sql} = buildSearchSql({lists: ['tuning']})
    const ranking = sql.slice(sql.indexOf('FROM ('), sql.indexOf(') AS ranked'))

    assert.match(ranking, /SELECT\s+messages_fts\.rowid AS id,\s+bm25\(/)
    assert.doesNotMatch(ranking, /snippet\(/)
    assert.doesNotMatch(ranking, /\bm\./)
    // The filter join reaches the covering index by rowid, never a message body.
    assert.match(ranking, /JOIN messages f ON f\.id = messages_fts\.rowid/)
    assert.match(sql, /JOIN messages m ON m\.id = ranked\.id/)
})

// SQLite 3.35 — the version inside the browser's WASM engine — otherwise reads
// the outer query as free to reorder, scans the whole match set a second time
// and fetches every matched message, which is the cost the LIMIT exists to
// avoid. The ranked rows number at most `limit` and both joins match on a
// rowid, so leading with them is right on every version.
test('buildSearchSql makes the ranked rows drive the joins that read them', () => {
    const {sql} = buildSearchSql({})
    const outer = sql.slice(sql.indexOf(') AS ranked'))

    assert.match(outer, /CROSS JOIN messages_fts ON messages_fts\.rowid = ranked\.id/)
    assert.match(outer, /CROSS JOIN messages m ON m\.id = ranked\.id/)

    // The filter join stays reorderable: a single-topic filter is genuinely
    // better driven from the messages table than from the full-text index.
    const filtered = buildSearchSql({topicId: 5}).sql
    const filterRanking = filtered.slice(filtered.indexOf('FROM ('), filtered.indexOf(') AS ranked'))
    assert.doesNotMatch(filterRanking, /CROSS JOIN/)
})

test('buildSearchSql joins the messages table only when a filter needs it', () => {
    assert.doesNotMatch(buildSearchSql({}).sql, /JOIN messages f/)
    assert.match(buildSearchSql({topicId: 5}).sql, /JOIN messages f/)
})

test('quoteEachTerm turns free text into a safe FTS phrase-per-word query', () => {
    assert.equal(quoteEachTerm('porcupine  "unbalanced'), '"porcupine" "unbalanced"')
    assert.equal(quoteEachTerm('  '), '')
})
