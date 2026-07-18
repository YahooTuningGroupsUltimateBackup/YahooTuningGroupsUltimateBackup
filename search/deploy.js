const crypto = require('node:crypto')
const fs = require('node:fs')
const path = require('node:path')
const {DatabaseSync} = require('node:sqlite')
const {openIndex} = require('./db')

const STATIC_SEARCH_DIR = path.join(__dirname, '..', 'static', 'search')
const SHARED_QUERY_SQL = path.join(__dirname, 'querySql.js')

const DEPLOY_PAGE_SIZE = 1024
const DEFAULT_CHUNK_BYTES = 10 * 1024 * 1024
const CHUNK_PREFIX = 'db.sqlite3.'
const SUFFIX_LENGTH = 3

// Rewrites a copy of the index for serving from a static host via HTTP range
// requests (sql.js-httpvfs): journal_mode=delete, merged FTS segments, small
// pages so each request fetches little, split into chunks under GitHub's
// per-file size limit.
const buildDeployDb = (indexDbPath, outDir, {chunkBytes = DEFAULT_CHUNK_BYTES} = {}) => {
    fs.mkdirSync(outDir, {recursive: true})
    const deployDbPath = path.join(outDir, 'deploy.sqlite3.tmp')
    fs.copyFileSync(indexDbPath, deployDbPath)

    const db = new DatabaseSync(deployDbPath)
    db.exec('PRAGMA journal_mode = DELETE')
    db.exec("INSERT INTO messages_fts(messages_fts) VALUES('optimize')")
    db.exec(`PRAGMA page_size = ${DEPLOY_PAGE_SIZE}`)
    db.exec('VACUUM')
    db.close()

    const databaseLengthBytes = fs.statSync(deployDbPath).size
    // Content-derived cache buster: the engine appends it to chunk URLs, so a
    // redeployed database never mixes with a browser's cache of the old one.
    const cacheBust = crypto.createHash('sha256').update(fs.readFileSync(deployDbPath)).digest('hex').slice(0, 16)
    const chunkCount = writeChunks(deployDbPath, outDir, chunkBytes)
    fs.rmSync(deployDbPath)

    fs.writeFileSync(path.join(outDir, 'config.json'), JSON.stringify({
        serverMode: 'chunked',
        requestChunkSize: DEPLOY_PAGE_SIZE,
        databaseLengthBytes,
        serverChunkSize: chunkBytes,
        urlPrefix: CHUNK_PREFIX,
        suffixLength: SUFFIX_LENGTH,
        cacheBust,
    }, null, 2))

    return {databaseLengthBytes, chunkCount}
}

const writeChunks = (filePath, outDir, chunkBytes) => {
    const fd = fs.openSync(filePath, 'r')
    const buffer = Buffer.alloc(chunkBytes)
    let chunkIndex = 0

    try {
        while (true) {
            const bytesRead = fs.readSync(fd, buffer, 0, chunkBytes, chunkIndex * chunkBytes)
            if (!bytesRead) break
            const suffix = String(chunkIndex).padStart(SUFFIX_LENGTH, '0')
            fs.writeFileSync(path.join(outDir, `${CHUNK_PREFIX}${suffix}`), buffer.subarray(0, bytesRead))
            chunkIndex += 1
        }
    } finally {
        fs.closeSync(fd)
    }

    return chunkIndex
}

// Assembles everything the static host needs on top of the parsed site: the
// search page, the vendored WASM engine, the list names, the chunked database,
// and a .nojekyll marker so GitHub Pages publishes the files verbatim.
const deploySite = (indexDbPath, distDir) => {
    const searchDir = path.join(distDir, 'search')
    fs.mkdirSync(searchDir, {recursive: true})

    // static/search includes lib/: the vendored sql.js-httpvfs 0.8.12 dist plus
    // the PATCH(ytgub) fix for CDNs that answer a cold Range request with 200.
    fs.cpSync(STATIC_SEARCH_DIR, searchDir, {recursive: true})
    fs.copyFileSync(SHARED_QUERY_SQL, path.join(searchDir, 'querySql.js'))

    const index = openIndex(indexDbPath)
    fs.writeFileSync(path.join(searchDir, 'lists.json'), JSON.stringify(index.lists()))
    index.close()

    fs.writeFileSync(path.join(distDir, '.nojekyll'), '\n')

    return buildDeployDb(indexDbPath, path.join(searchDir, 'db'))
}

module.exports = {buildDeployDb, deploySite}
