const {test} = require('node:test')
const assert = require('node:assert/strict')
const http = require('node:http')
const path = require('node:path')
const {openIndex} = require('../search/db')
const {createApp} = require('../search/app')

const FIXTURE_DIST = path.join(__dirname, 'fixtures', 'dist')

const get = (server, pathname) => new Promise((resolve, reject) => {
    const {port} = server.address()
    http.get(`http://127.0.0.1:${port}${pathname}`, response => {
        let body = ''
        response.on('data', chunk => body += chunk)
        response.on('end', () => resolve({status: response.statusCode, body}))
    }).on('error', reject)
})

const listen = (t, app) => {
    const server = app.listen(0)
    t.after(() => server.close())
    return server
}

const indexWithOneMessage = () => {
    const index = openIndex(':memory:')
    index.addDocs([{
        list: 'tuning',
        msgId: 42,
        topicId: 7,
        postDate: 990420885,
        author: 'Paul Erlich',
        subject: 'porcupine temperament',
        body: 'The porcupine comma vanishes & disappears.',
    }, {
        list: 'mills-tuning-list',
        msgId: 2000,
        topicId: null,
        postDate: 811269927,
        author: 'Gary Morrison',
        subject: 'Note Doubling',
        body: 'doubling notes in octaves',
    }])
    return index
}

test('GET /search renders a form and, given a query, results linking to local and online pages', async t => {
    const server = listen(t, createApp({index: indexWithOneMessage()}))

    const formOnly = await get(server, '/search')
    assert.equal(formOnly.status, 200)
    assert.match(formOnly.body, /<form[^>]*action="\/search"/)
    assert.match(formOnly.body, /name="q"/)
    assert.match(formOnly.body, /<option value="tuning">/)

    const rows = formOnly.body
        .match(/<form action="\/search" method="get">[\s\S]*?<\/form>/)[0]
        .match(/<div>[\s\S]*?<\/div>/g)
    assert.equal(rows.length, 4)
    assert.match(rows[0], /name="q"[\s\S]*<button>/)
    assert.match(rows[1], /name="list"/)
    assert.match(rows[2], /name="author"/)
    assert.doesNotMatch(rows[2], /name="(q|list|after|before)"/)
    assert.match(rows[3], /name="after"[\s\S]*name="before"/)

    const results = await get(server, '/search?q=porcupine')
    assert.equal(results.status, 200)
    assert.match(results.body, /porcupine temperament/)
    assert.match(results.body, /Paul Erlich/)
    assert.match(results.body, /href="\/tuning\/message\/42\.html"/)
    assert.match(results.body, /href="https:\/\/yahootuninggroupsultimatebackup\.github\.io\/tuning\/message\/42\.html"/)
    assert.match(results.body, /2001-05-21/)

    const noMatches = await get(server, '/search?q=zebra')
    assert.equal(noMatches.status, 200)
    assert.match(noMatches.body, /no matches/i)
})

test('GET /search escapes markup in queries and message fields', async t => {
    const index = openIndex(':memory:')
    index.addDocs([{
        list: 'tuning',
        msgId: 1,
        topicId: 1,
        postDate: 990420885,
        author: 'Evil <script>alert(1)</script>',
        subject: 'xss & entities',
        body: 'xss attempt here',
    }])
    const server = listen(t, createApp({index}))

    const results = await get(server, '/search?q=xss&author=%3Cb%3E')
    assert.equal(results.status, 200)
    assert.doesNotMatch(results.body, /<script>alert/)
    assert.doesNotMatch(results.body, /value="<b>"/)
})

test('GET /search without a built index explains how to build one', async t => {
    const server = listen(t, createApp({index: null}))

    const {status, body} = await get(server, '/search?q=porcupine')
    assert.equal(status, 200)
    assert.match(body, /node search\.js build/)
})

test('archive pages are served verbatim — search bars are baked in at parse time, not injected', async t => {
    const server = listen(t, createApp({index: indexWithOneMessage(), distDir: FIXTURE_DIST}))

    const topicPage = await get(server, '/tuning/topicId_5.html')
    assert.equal(topicPage.status, 200)
    assert.match(topicPage.body, /TOPIC_PAGE_MARKER/)
    assert.doesNotMatch(topicPage.body, /<form/)
})

test('message redirect pages are served untouched', async t => {
    const server = listen(t, createApp({index: indexWithOneMessage(), distDir: FIXTURE_DIST}))

    const redirect = await get(server, '/tuning/message/42.html')
    assert.equal(redirect.status, 200)
    assert.match(redirect.body, /http-equiv="Refresh"/)
    assert.doesNotMatch(redirect.body, /<form/)
})

test('pages that are not generated yet get a hint to run make parse instead of a bare 404', async t => {
    const server = listen(t, createApp({index: indexWithOneMessage(), distDir: path.join(FIXTURE_DIST, 'no-such-dist')}))

    const {status, body} = await get(server, '/')
    assert.equal(status, 404)
    assert.match(body, /make parse/)
    assert.match(body, /\/search/)
})

test('GET /search scopes results to a topic when asked and offers a way to clear it', async t => {
    const index = openIndex(':memory:')
    index.addDocs([
        {list: 'tuning', msgId: 1, topicId: 5, postDate: 990420885, author: 'A', subject: 'porcupine one', body: 'porcupine in topic five'},
        {list: 'tuning', msgId: 2, topicId: 6, postDate: 990420885, author: 'B', subject: 'porcupine two', body: 'porcupine in topic six'},
    ])
    const server = listen(t, createApp({index}))

    const {status, body} = await get(server, '/search?q=porcupine&list=tuning&topic=5')
    assert.equal(status, 200)
    assert.match(body, /porcupine one/)
    assert.doesNotMatch(body, /porcupine two/)
    assert.match(body, /searching within “porcupine one”/)
    assert.match(body, /name="topic" type="hidden" value="5"/)
})
