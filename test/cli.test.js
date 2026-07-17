const {test} = require('node:test')
const assert = require('node:assert/strict')
const {execFileSync} = require('node:child_process')
const fs = require('node:fs')
const os = require('node:os')
const path = require('node:path')

const CLI = path.join(__dirname, '..', 'search.js')
const FIXTURE_SRC = path.join(__dirname, 'fixtures', 'src')

const runCli = (args, options = {}) =>
    execFileSync(process.execPath, ['--disable-warning=ExperimentalWarning', CLI, ...args], {
        encoding: 'utf8',
        ...options,
    })

test('cli builds an index from src and searches it with filters', t => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ytgub-search-'))
    t.after(() => fs.rmSync(tmpDir, {recursive: true, force: true}))
    const db = path.join(tmpDir, 'index.db')

    const buildOutput = runCli(['build', '--src', FIXTURE_SRC, '--db', db])
    assert.match(buildOutput, /tuning: 1/)
    assert.match(buildOutput, /mills-tuning-list: 1/)
    assert.match(buildOutput, /indexed 3 messages/)

    const searchOutput = runCli(['lattice', '--db', db])
    assert.match(searchOutput, /tuning #1  monz/)
    assert.match(searchOutput, /lattice diagrams/)
    assert.match(searchOutput, /https:\/\/yahootuninggroupsultimatebackup\.github\.io\/tuning\/message\/1\.html/)

    const filteredOutput = runCli(['doubling', '--list', 'mills-tuning-list,tuning', '--db', db])
    assert.match(filteredOutput, /mills-tuning-list #2000/)

    const excludedOutput = runCli(['doubling', '--list', 'tuning', '--db', db])
    assert.match(excludedOutput, /no matches/i)
})

test('cli exits nonzero with usage when called without a query, and with guidance when the index is missing', t => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ytgub-search-'))
    t.after(() => fs.rmSync(tmpDir, {recursive: true, force: true}))

    const failure = (...args) => {
        try {
            runCli(...args)
            assert.fail('expected the cli to exit nonzero')
        } catch (error) {
            return error
        }
    }

    const noArgs = failure([], {stdio: 'pipe'})
    assert.equal(noArgs.status, 1)
    assert.match(noArgs.stderr, /usage:/)

    const missingDb = failure(['lattice', '--db', path.join(tmpDir, 'nope.db')], {stdio: 'pipe'})
    assert.equal(missingDb.status, 1)
    assert.match(missingDb.stderr, /build it first/)
    assert.equal(fs.existsSync(path.join(tmpDir, 'nope.db')), false)
})
