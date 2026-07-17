const he = require('he')
const {simpleParser} = require('mailparser')

const yahooMessageToDoc = async (list, message) => {
    let body
    if (message.rawEmail) {
        const email = await simpleParser(he.decode(message.rawEmail))
        body = email.text || ''
    } else {
        body = he.decode(message.msgSnippet || '')
    }

    return {
        list,
        msgId: message.msgId,
        topicId: message.topicId,
        postDate: Number(message.postDate),
        author: message.authorName,
        subject: he.decode(message.subject || ''),
        body: body.trim(),
    }
}

const headerValue = (lines, prefix) =>
    (lines.find(line => line.startsWith(prefix)) || '').slice(prefix.length)

const millsFileToDoc = (filename, content) => {
    const lines = content.split('\n')
    const headerLines = lines.slice(0, 7)
    const postDateMs = Date.parse(headerValue(headerLines, 'Date: '))

    return {
        list: 'mills-tuning-list',
        msgId: parseInt(filename.replace('msg____', ''), 10),
        topicId: null,
        postDate: Number.isNaN(postDateMs) ? null : postDateMs / 1000,
        author: headerValue(headerLines, 'From: '),
        subject: headerValue(headerLines, 'Subject: '),
        body: lines.slice(7).join('\n').trim(),
    }
}

module.exports = {yahooMessageToDoc, millsFileToDoc}
