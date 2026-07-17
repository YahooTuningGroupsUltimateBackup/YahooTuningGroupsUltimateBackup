const {test} = require('node:test')
const assert = require('node:assert/strict')
const {searchOptions} = require('../search/options')

test('searchOptions converts raw string inputs into index.search options', () => {
    assert.deepEqual(searchOptions({}), {
        lists: undefined,
        author: undefined,
        after: undefined,
        before: undefined,
        limit: undefined,
    })

    assert.deepEqual(searchOptions({
        lists: ['tuning-math,metatuning', 'tuning'],
        author: 'erlich',
        after: '2001',
        before: '2002-06',
        limit: '5',
    }), {
        lists: ['tuning-math', 'metatuning', 'tuning'],
        author: 'erlich',
        after: Date.parse('2001') / 1000,
        before: Date.parse('2002-06') / 1000,
        limit: 5,
    })

    assert.throws(() => searchOptions({after: 'not-a-date'}), /invalid date: not-a-date/)
    assert.throws(() => searchOptions({limit: 'zero'}), /invalid limit: zero/)
})
