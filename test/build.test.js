const {test} = require('node:test')
const assert = require('node:assert/strict')
const path = require('node:path')
const {openIndex} = require('../search/db')
const {buildIndex} = require('../search/build')

const FIXTURE_SRC = path.join(__dirname, 'fixtures', 'src')

test('buildIndex indexes yahoo lists and mills messages from a src tree', async () => {
    const index = openIndex(':memory:')

    const counts = await buildIndex(FIXTURE_SRC, index)

    assert.deepEqual(counts, {'mills-tuning-list': 1, 'tuning': 2, 'tuning-math': 1})

    const lattice = index.search('lattice')
    assert.equal(lattice.length, 1)
    assert.equal(lattice[0].list, 'tuning')
    assert.equal(lattice[0].author, 'monz')

    const snippetOnly = index.search('schismatic')
    assert.equal(snippetOnly.length, 1)
    assert.equal(snippetOnly[0].msgId, 2)

    const quotedPrintable = index.search('tetrachord')
    assert.equal(quotedPrintable.length, 1)
    assert.equal(quotedPrintable[0].list, 'tuning-math')

    const mills = index.search('doubling')
    assert.equal(mills.length, 1)
    assert.equal(mills[0].list, 'mills-tuning-list')
    assert.equal(mills[0].msgId, 2000)
})
