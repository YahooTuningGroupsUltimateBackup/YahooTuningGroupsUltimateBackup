// Opens the browser search page — the one that runs SQLite in WebAssembly and
// reads the database over HTTP range requests — against the real index in
// dist/. A file:// copy cannot show it: the engine needs a server that answers
// range requests, which is all this is, plus a launcher so the page opens on a
// double-click.
const fs = require('node:fs')
const http = require('node:http')
const path = require('node:path')
const {spawn} = require('node:child_process')

const PORT = 4320
const DIST = path.join(__dirname, '..', 'dist')
const LAUNCHER = path.join(DIST, 'Search demo.vbs')
const OPENS_AT = `http://localhost:${PORT}/search/`

const TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.js': 'text/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.wasm': 'application/wasm',
}

// Rewritten every run so it survives dist/ being rebuilt or cleared; dist/ is
// gitignored, and a launcher that vanishes with it is no mechanism at all.
const writeLauncher = () => fs.writeFileSync(LAUNCHER, [
    '\' Starts the search demo with no console window, then opens the page.',
    'Set shell = CreateObject("WScript.Shell")',
    `shell.Run "node ""${path.join(__dirname, 'searchDemo.js')}""", 0, False`,
    'WScript.Sleep 1500',
    `shell.Run "${OPENS_AT}", 1, False`,
].join('\r\n') + '\r\n')

const send = (response, status, headers, body) => {
    response.writeHead(status, headers)
    if (body) body.pipe(response)
    else response.end()
}

const serve = (request, response) => {
    const requested = decodeURIComponent(new URL(request.url, OPENS_AT).pathname)
    const relative = requested.endsWith('/') ? `${requested}index.html` : requested
    const file = path.join(DIST, relative)

    if (!file.startsWith(DIST) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
        send(response, 404, {'content-type': 'text/plain'})
        return
    }

    const size = fs.statSync(file).size
    const type = TYPES[path.extname(file)] || 'application/octet-stream'
    // The database chunks are read a kilobyte at a time; without ranges the
    // engine would pull all 474MB of them.
    const range = /bytes=(\d*)-(\d*)/.exec(request.headers.range || '')

    if (!range) {
        send(response, 200, {'content-type': type, 'content-length': size, 'accept-ranges': 'bytes'},
            fs.createReadStream(file))
        return
    }

    const start = Number(range[1] || 0)
    const end = Math.min(Number(range[2] || size - 1), size - 1)
    send(response, 206, {
        'content-type': type,
        'content-length': end - start + 1,
        'content-range': `bytes ${start}-${end}/${size}`,
        'accept-ranges': 'bytes',
    }, fs.createReadStream(file, {start, end}))
}

if (!fs.existsSync(path.join(DIST, 'search', 'db', 'config.json'))) {
    console.error(`no search database in ${DIST}\\search — build one with: node search.js deploy-site`)
    process.exit(1)
}

writeLauncher()
http.createServer(serve).listen(PORT, () => {
    console.log(`search demo at ${OPENS_AT} — launcher written to ${LAUNCHER}`)
    if (!process.argv.includes('--no-open')) spawn('cmd', ['/c', 'start', '', OPENS_AT], {detached: true}).unref()
})
