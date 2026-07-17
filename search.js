const fs = require('node:fs')
const {parseArgs} = require('node:util')
const {openIndex} = require('./search/db')
const {formatResult} = require('./search/format')
const {searchOptions} = require('./search/options')

const DEFAULT_DB = 'search-index.db'

const USAGE = `usage:
  node search.js build [--src <dir>] [--db <file>]
  node search.js <query> [--list <name>[,<name>...]] [--author <text>]
                 [--after <date>] [--before <date>] [--limit <n>] [--db <file>]

The query uses SQLite FTS5 syntax: bare words are ANDed, "quoted phrases",
OR, NOT, and NEAR(a b, n) are supported. Dates are YYYY[-MM[-DD]].

examples:
  node search.js build
  node search.js "porcupine temperament" --list tuning-math --limit 10
  node search.js miracle --author erlich --after 2001 --before 2002-06`

const die = message => {
    console.error(message)
    process.exit(1)
}

const build = async ({src, db}) => {
    // Required lazily: building needs the npm deps (mailparser, he), querying does not.
    const {buildIndex} = require('./search/build')

    fs.rmSync(db, {force: true})
    const index = openIndex(db)
    const startedAt = Date.now()

    const lastLogged = {}
    const counts = await buildIndex(src, index, (list, indexed) => {
        if (indexed - (lastLogged[list] || 0) >= 5000) {
            console.log(`${list}: indexed ${indexed} messages so far`)
            lastLogged[list] = indexed
        }
    })
    index.close()

    Object.entries(counts).forEach(([list, count]) => console.log(`${list}: ${count}`))
    const total = Object.values(counts).reduce((sum, count) => sum + count, 0)
    const seconds = Math.round((Date.now() - startedAt) / 1000)
    console.log(`indexed ${total} messages into ${db} in ${seconds}s`)
}

const search = (query, {db, list, author, after, before, limit}) => {
    if (!fs.existsSync(db)) die(`no search index at ${db} — build it first with: node search.js build`)

    let options
    try {
        options = searchOptions({lists: list, author, after, before, limit})
    } catch (error) {
        die(`${error.message}\n\n${USAGE}`)
    }
    const results = openIndex(db).search(query, options)

    if (!results.length) {
        console.log('no matches')
        return
    }

    console.log(results.map(formatResult).join('\n\n'))
}

const main = async () => {
    let parsed
    try {
        parsed = parseArgs({
            options: {
                db: {type: 'string', default: DEFAULT_DB},
                src: {type: 'string', default: 'src'},
                list: {type: 'string', multiple: true},
                author: {type: 'string'},
                after: {type: 'string'},
                before: {type: 'string'},
                limit: {type: 'string'},
            },
            allowPositionals: true,
        })
    } catch (error) {
        die(`${error.message}\n\n${USAGE}`)
    }
    const {values, positionals} = parsed

    if (positionals[0] === 'build') {
        await build(values)
    } else if (positionals.length) {
        search(positionals.join(' '), values)
    } else {
        die(USAGE)
    }
}

main().catch(error => {
    console.error(error)
    process.exit(1)
})
