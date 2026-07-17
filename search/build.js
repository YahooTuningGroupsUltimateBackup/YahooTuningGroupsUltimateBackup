const fs = require('node:fs')
const path = require('node:path')
const {yahooMessageToDoc, millsFileToDoc} = require('./extract')

const CHUNK_SIZE = 500

const noProgress = () => {}

const buildYahooList = async (srcRoot, list, index, onProgress) => {
    const messagesDir = path.join(srcRoot, list, 'messages')
    let indexed = 0

    for (const messagesFilename of fs.readdirSync(messagesDir)) {
        const messages = JSON.parse(fs.readFileSync(path.join(messagesDir, messagesFilename)))

        for (let start = 0; start < messages.length; start += CHUNK_SIZE) {
            const chunk = messages.slice(start, start + CHUNK_SIZE)
            const docs = await Promise.all(chunk.map(message => yahooMessageToDoc(list, message)))
            index.addDocs(docs)
            indexed += docs.length
            onProgress(list, indexed)
        }
    }

    return indexed
}

const buildMillsList = (srcRoot, list, index, onProgress) => {
    const listDir = path.join(srcRoot, list)
    let indexed = 0
    let docs = []

    for (const filename of fs.readdirSync(listDir)) {
        docs.push(millsFileToDoc(filename, fs.readFileSync(path.join(listDir, filename)).toString()))

        if (docs.length === CHUNK_SIZE) {
            index.addDocs(docs)
            indexed += docs.length
            onProgress(list, indexed)
            docs = []
        }
    }

    index.addDocs(docs)
    indexed += docs.length
    onProgress(list, indexed)

    return indexed
}

const buildIndex = async (srcRoot, index, onProgress = noProgress) => {
    const counts = {}

    for (const list of fs.readdirSync(srcRoot)) {
        if (list === 'mills-tuning-list') {
            counts[list] = buildMillsList(srcRoot, list, index, onProgress)
        } else if (fs.existsSync(path.join(srcRoot, list, 'messages'))) {
            counts[list] = await buildYahooList(srcRoot, list, index, onProgress)
        }
    }

    return counts
}

module.exports = {buildIndex}
