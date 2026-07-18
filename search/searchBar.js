const he = require('he')

const SEARCH_BAR_STYLE = 'margin: 10px 20px; padding: 10px 20px; background-color: #ddd'

const escape = value => he.encode(String(value ?? ''))

// Baked into every generated archive page, pre-scoped to the list (and, on a
// topic page, the topic) the reader is already looking at. Posts to /search/,
// which is the express route locally and the static search page when deployed.
const searchBarHtml = ({list, topicId}) => `
    <form action="/search/" method="get" style="${SEARCH_BAR_STYLE}">
        <div>
            <input type="text" name="q" size="40" placeholder="search the archive">
            <button>search</button>
            <a href="/search/">advanced</a>
        </div>
        ${list ? `<div>
            <select name="list">
                <option value="${escape(list)}" selected>${escape(list)}</option>
                <option value="">all lists</option>
            </select>
            ${topicId ? `<label><input name="topic" value="${topicId}" checked type="checkbox"> this topic only</label>` : ''}
        </div>` : ''}
    </form>
`

module.exports = {searchBarHtml}
