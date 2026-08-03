const he = require('he')

const escape = value => he.encode(String(value ?? ''))

// Baked into every generated archive page: the full search form, pre-scoped to
// the list (and, on a topic page, the topic) the reader is already looking at.
// Posts to /search/, which is the express route locally and the static search
// page when deployed.
const searchBarHtml = ({list, topicId}) => `
    <form action="/search/" method="get" class="search-bar">
        <div>
            <input type="text" name="q" size="40" placeholder="search the archive">
            <button>search</button>
        </div>
        ${list ? `<div>
            <select name="list">
                <option value="${escape(list)}" selected>${escape(list)}</option>
                <option value="">all lists</option>
            </select>
            ${topicId ? `<label><input name="topic" value="${topicId}" checked type="checkbox"> this topic only</label>` : ''}
        </div>` : ''}
        <div>
            <label>author <input type="text" name="author"></label>
        </div>
        <div>
            <label>after <input type="text" name="after" size="10" placeholder="2001-05"></label>
            <label>before <input type="text" name="before" size="10" placeholder="2003"></label>
        </div>
    </form>
`

module.exports = {searchBarHtml}
