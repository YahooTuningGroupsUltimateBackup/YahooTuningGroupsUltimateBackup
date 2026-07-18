const {test} = require('node:test')
const assert = require('node:assert/strict')
const {searchBarHtml} = require('../search/searchBar')

const rows = html => html.match(/<div>[\s\S]*?<\/div>/g)

test('searchBarHtml renders query row plus scope row matching where the page sits', () => {
    const root = searchBarHtml({})
    assert.match(root, /<form action="\/search\/" method="get"/)
    assert.equal(rows(root).length, 1)
    assert.match(rows(root)[0], /name="q"[\s\S]*<button>search<\/button>[\s\S]*advanced/)
    assert.doesNotMatch(root, /name="(list|topic)"/)

    const listScoped = searchBarHtml({list: 'tuning'})
    assert.equal(rows(listScoped).length, 2)
    assert.match(rows(listScoped)[1], /<option value="tuning" selected>/)
    assert.match(rows(listScoped)[1], /<option value="">all lists<\/option>/)
    assert.doesNotMatch(listScoped, /name="topic"/)

    const topicScoped = searchBarHtml({list: 'tuning', topicId: 5})
    assert.equal(rows(topicScoped).length, 2)
    assert.match(rows(topicScoped)[1], /name="list"[\s\S]*name="topic" value="5" checked[\s\S]*this topic only/)
})
