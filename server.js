const fs = require('fs')
const {openIndex} = require('./search/db')
const {createApp} = require('./search/app')

const SEARCH_INDEX_DB = 'search-index.db'

const index = fs.existsSync(SEARCH_INDEX_DB) ? openIndex(SEARCH_INDEX_DB) : null
createApp({index}).listen(3000)
console.log('serving the archive at http://localhost:3000 — search at http://localhost:3000/search')
