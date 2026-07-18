const {test} = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const os = require('node:os')
const path = require('node:path')
const {DatabaseSync} = require('node:sqlite')
const {openIndex} = require('../search/db')
const {buildDeployDb, deploySite} = require('../search/deploy')

test('buildDeployDb rewrites the index at 1KB pages into chunk files that reassemble into a queryable db', t => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ytgub-deploy-'))
    t.after(() => fs.rmSync(tmpDir, {recursive: true, force: true}))

    const indexPath = path.join(tmpDir, 'index.db')
    const index = openIndex(indexPath)
    index.addDocs([{
        list: 'tuning',
        msgId: 1,
        topicId: 7,
        postDate: 990420885,
        author: 'Paul Erlich',
        subject: 'porcupine temperament',
        body: 'The porcupine comma vanishes.',
    }])
    index.close()

    const outDir = path.join(tmpDir, 'out')
    const chunkBytes = 8192
    const {databaseLengthBytes, chunkCount} = buildDeployDb(indexPath, outDir, {chunkBytes})

    const {cacheBust, ...config} = JSON.parse(fs.readFileSync(path.join(outDir, 'config.json')))
    assert.deepEqual(config, {
        serverMode: 'chunked',
        requestChunkSize: 1024,
        databaseLengthBytes,
        serverChunkSize: chunkBytes,
        urlPrefix: 'db.sqlite3.',
        suffixLength: 3,
    })
    // Content-derived so every redeploy busts browser caches of the previous db's chunks.
    assert.match(cacheBust, /^[0-9a-f]{16}$/)

    const chunkNames = fs.readdirSync(outDir).filter(name => name.startsWith('db.sqlite3.')).sort()
    assert.equal(chunkNames.length, chunkCount)
    assert.equal(chunkNames[0], 'db.sqlite3.000')
    assert.equal(chunkCount, Math.ceil(databaseLengthBytes / chunkBytes))
    assert.ok(chunkCount > 1)

    const reassembled = path.join(tmpDir, 'reassembled.db')
    fs.writeFileSync(reassembled, Buffer.concat(chunkNames.map(name => fs.readFileSync(path.join(outDir, name)))))
    assert.equal(fs.statSync(reassembled).size, databaseLengthBytes)

    const db = new DatabaseSync(reassembled)
    try {
        assert.equal(db.prepare('PRAGMA page_size').get().page_size, 1024)
        assert.equal(db.prepare('PRAGMA journal_mode').get().journal_mode, 'delete')
        const hits = db.prepare("SELECT m.subject FROM messages_fts JOIN messages m ON m.id = messages_fts.rowid WHERE messages_fts MATCH 'porcupine'").all()
        assert.equal(hits.length, 1)
        assert.equal(hits[0].subject, 'porcupine temperament')
    } finally {
        db.close()
    }

    assert.ok(!fs.readdirSync(outDir).some(name => name.includes('tmp')), 'no temp files left in out dir')
})

test('deploySite assembles the static search page, vendored engine, db chunks, and .nojekyll into dist', t => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ytgub-site-'))
    t.after(() => fs.rmSync(tmpDir, {recursive: true, force: true}))

    const indexPath = path.join(tmpDir, 'index.db')
    const index = openIndex(indexPath)
    index.addDocs([{list: 'tuning', msgId: 1, topicId: 1, postDate: 1, author: 'a', subject: 's', body: 'b'}])
    index.close()

    const distDir = path.join(tmpDir, 'dist')
    fs.mkdirSync(distDir)

    const {chunkCount} = deploySite(indexPath, distDir)

    const expectFile = relative => assert.ok(
        fs.existsSync(path.join(distDir, relative)) && fs.statSync(path.join(distDir, relative)).size > 0,
        `missing ${relative}`,
    )
    expectFile('.nojekyll')
    expectFile('search/index.html')
    expectFile('search/search-page.js')
    expectFile('search/querySql.js')
    expectFile('search/lib/index.js')
    expectFile('search/lib/sqlite.worker.js')
    expectFile('search/lib/sql-wasm.wasm')
    expectFile('search/db/config.json')
    expectFile('search/db/db.sqlite3.000')
    assert.ok(chunkCount >= 1)
    assert.deepEqual(JSON.parse(fs.readFileSync(path.join(distDir, 'search', 'lists.json'))), ['tuning'])

    // The vendored engine must carry both CDN-serving patches: cold Range
    // requests answered with 200 + the whole file (GitHub Pages does this),
    // and readaheads that would run past a chunk file's end.
    const worker = fs.readFileSync(path.join(distDir, 'search', 'lib', 'sqlite.worker.js'), 'utf8')
    assert.match(worker, /PATCH\(ytgub\): cold Range/)
    assert.match(worker, /PATCH\(ytgub\): range clamp/)
})
