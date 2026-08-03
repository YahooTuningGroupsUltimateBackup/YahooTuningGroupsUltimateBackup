const {test} = require('node:test')
const assert = require('node:assert/strict')
const {searchBarHtml} = require('../search/searchBar')

const rows = html => html.match(/<div>[\s\S]*?<\/div>/g)

test('searchBarHtml renders the full filter form scoped to where the page sits', () => {
    const root = searchBarHtml({})
    assert.match(root, /<form action="\/search\/" method="get" class="search-bar"/)
    assert.doesNotMatch(root, /style=/)
    assert.equal(rows(root).length, 3)
    assert.match(rows(root)[0], /name="q"[\s\S]*<button>search<\/button>/)
    assert.match(rows(root)[1], /name="author"/)
    assert.match(rows(root)[2], /name="after"[\s\S]*name="before"/)
    assert.doesNotMatch(root, /name="(list|topic)"/)
    assert.doesNotMatch(root, /advanced/)

    const listScoped = searchBarHtml({list: 'tuning'})
    assert.equal(rows(listScoped).length, 4)
    assert.match(rows(listScoped)[1], /<option value="tuning" selected>/)
    assert.match(rows(listScoped)[1], /<option value="">all lists<\/option>/)
    assert.match(rows(listScoped)[2], /name="author"/)
    assert.match(rows(listScoped)[3], /name="after"[\s\S]*name="before"/)
    assert.doesNotMatch(listScoped, /name="topic"/)

    const topicScoped = searchBarHtml({list: 'tuning', topicId: 5})
    assert.equal(rows(topicScoped).length, 4)
    assert.match(rows(topicScoped)[1], /name="list"[\s\S]*name="topic" value="5" checked[\s\S]*this topic only/)
})
