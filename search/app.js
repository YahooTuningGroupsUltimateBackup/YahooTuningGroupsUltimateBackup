const express = require('express')
const he = require('he')
const {messageUrl, isoDate} = require('./format')
const {searchOptions} = require('./options')

const RESULT_STYLE = 'margin: 20px; padding: 10px 20px; background-color: #eee'

const escape = value => he.encode(String(value ?? ''))

const highlightSnippet = escapedSnippet => escapedSnippet.replace(/\[([^\]]*)\]/g, '<mark>$1</mark>')

const page = content => `<!DOCTYPE html>
    <html>
    <head>
    <meta charset="utf-8">
        <meta name="viewport"
    content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
        <meta http-equiv="x-ua-compatible" content="ie=edge">
        <title>Yahoo Tuning Groups Ultimate Backup Search</title>
    </head>
    <body>
    <a href='/'>back to root</a>
    <h1>Search</h1>
    ${content}
    </body>
    </html>
`

const formHtml = (lists, {q, list, author, after, before}) => `
    <form action="/search" method="get">
        <input type="text" name="q" size="60" value="${escape(q)}" placeholder="FTS5 query: bare words, &quot;phrases&quot;, OR, NOT, NEAR()">
        <button>search</button>
        <div>
            <label>list
                <select name="list">
                    <option value="">all lists</option>
                    ${lists.map(name => `<option value="${escape(name)}"${name === list ? ' selected' : ''}>${escape(name)}</option>`).join('\n                    ')}
                </select>
            </label>
            <label>author <input type="text" name="author" value="${escape(author)}"></label>
            <label>after <input type="text" name="after" size="10" value="${escape(after)}" placeholder="2001-05"></label>
            <label>before <input type="text" name="before" size="10" value="${escape(before)}" placeholder="2003"></label>
        </div>
    </form>
`

const resultHtml = ({list, msgId, postDate, author, subject, snippet}) => `
    <div style="${RESULT_STYLE}">
        <div>${escape(isoDate(postDate))} · ${escape(list)} #${msgId} · ${escape(author)}</div>
        <h3><a href="/${escape(list)}/message/${msgId}.html">${escape(subject)}</a></h3>
        <p>${highlightSnippet(escape(snippet))}</p>
        <a target=_blank href="${messageUrl(list, msgId)}">view online</a>
    </div>
`

const resultsHtml = (index, {q, list, author, after, before}) => {
    if (!q.trim()) return ''

    let results
    try {
        results = index.search(q, searchOptions({
            lists: list ? [list] : undefined,
            author,
            after,
            before,
        }))
    } catch (error) {
        return `<p>${escape(error.message)}</p>`
    }

    if (!results.length) return '<p>No matches.</p>'
    return results.map(resultHtml).join('')
}

const MISSING_INDEX_HTML = `
    <p>No search index found. Build one first (takes a few minutes):</p>
    <pre>node search.js build</pre>
    <p>then restart the server.</p>
`

const createApp = ({index, distDir = 'dist'}) => {
    const app = express()

    app.get('/search', (req, res) => {
        if (!index) {
            res.send(page(MISSING_INDEX_HTML))
            return
        }

        const inputs = {
            q: String(req.query.q ?? ''),
            list: String(req.query.list ?? ''),
            author: String(req.query.author ?? ''),
            after: String(req.query.after ?? ''),
            before: String(req.query.before ?? ''),
        }
        res.send(page(formHtml(index.lists(), inputs) + resultsHtml(index, inputs)))
    })

    app.use(express.static(distDir))

    return app
}

module.exports = {createApp}
