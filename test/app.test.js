const {test} = require('node:test')
const assert = require('node:assert/strict')
const http = require('node:http')
const {openIndex} = require('../search/db')
const {createApp} = require('../search/app')

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
