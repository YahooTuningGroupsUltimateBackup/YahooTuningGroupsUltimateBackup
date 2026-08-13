const {test} = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')

const script = fs.readFileSync(path.join(__dirname, '..', 'static', 'search', 'search-page.js'), 'utf8')

// Stands in for the search page's DOM and the two globals its script tags
// provide, recording every status line it writes and every time it reaches for
// the engine.
const openPage = ({query = '', rows = [], engine} = {}) => {
    const statuses = []
    const created = []

    const element = () => {
        const node = {
            value: '',
            textContent: '',
            selected: false,
            children: [],
            style: {},
            href: '',
            name: '',
            type: '',
            appendChild: child => node.children.push(child),
        }
        return node
    }

    const status = element()
    Object.defineProperty(status, 'textContent', {
        get: () => statuses[statuses.length - 1] || '',
        set: text => statuses.push(text),
    })

    const form = element()
    form.elements = {q: element(), author: element(), after: element(), before: element(), list: element()}

    const byId = {'search-form': form, status, results: element(), 'topic-scope': element()}

    const worker = engine || Promise.resolve({db: {query: async () => rows}})

    const run = new Function(
        'document', 'location', 'fetch', 'createDbWorker', 'ytgubQuerySql',
        `${script}\n//# sourceURL=search-page.js`,
    )
    run(
        {getElementById: id => byId[id], createElement: () => element(), createTextNode: text => ({text})},
        {search: query, href: 'https://example.test/search/'},
        async () => ({json: async () => []}),
        (...args) => { created.push(args); return worker },
        require('../search/querySql'),
    )

    return {statuses, engineStarts: () => created.length, results: byId.results}
}

// The engine is a megabyte of WebAssembly and a database read a page at a time
// over the network. Starting it only once a query needs it puts that wait in
// front of the reader; starting it when the page opens usually hides it behind
// the time they spend typing.
test('the engine starts loading as soon as the page opens, with nothing yet searched', () => {
    const page = openPage({query: ''})

    assert.equal(page.engineStarts(), 1)
})

test('a search does not start a second engine', async () => {
    const page = openPage({query: '?q=porcupine'})
    await new Promise(setImmediate)

    assert.equal(page.engineStarts(), 1)
})

// What the reader is told about is their own search. That the page runs on a
// database engine it has to fetch first is the page's business, not theirs.
test('the status line never mentions loading or the engine', async () => {
    const page = openPage({query: '?q=porcupine', rows: [
        {list: 'tuning', msgId: 1, postDate: 990420885, author: 'Paul Erlich', subject: 'porcupine', snippet: 'a [porcupine] comma'},
    ]})
    await new Promise(setImmediate)

    assert.ok(page.statuses.length, 'the page wrote no status at all')
    page.statuses.forEach(text => assert.doesNotMatch(text, /loading|engine/i, `status line said "${text}"`))
    assert.equal(page.statuses[page.statuses.length - 1], '1 result')
})

// The wait to report is the search, and it covers the engine's own loading —
// otherwise a reader who searches before it is ready watches a blank page.
test('the page says it is searching from the moment the search starts', async () => {
    let ready
    const page = openPage({query: '?q=porcupine', engine: new Promise(resolve => (ready = resolve))})

    assert.deepEqual(page.statuses, ['searching…'])

    ready({db: {query: async () => []}})
    await new Promise(setImmediate)
    assert.equal(page.statuses[page.statuses.length - 1], 'No matches.')
})
