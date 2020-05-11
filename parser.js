const fs = require('fs')
const he = require('he')
const {simpleParser} = require('mailparser')

const ROOT_PAGE = 'dist/index.html'

const ATTACHMENT_STYLE = 'margin: 0px 20px; padding: 20px; background-color: #ddd'
const EMAIL_TEXT_STYLE = 'margin: 0px 20px 20px; padding: 20px; background-color: #eee'

const parsed = {}
const listMsgIdToTopicIdMap = {}

const deleteFolderRecursive = path => {
    if (!fs.existsSync(path)) return

    fs.readdirSync(path).forEach(file => {
        const curPath = `${path}/${file}`
        fs.lstatSync(curPath).isDirectory() ? deleteFolderRecursive(curPath) : fs.unlinkSync(curPath)
    })

    fs.rmdirSync(path)
}

const writeAttachmentHtml = (attachment, list, topicPage) => {
    const attachmentFilename = attachment.filename
    const attachmentPath = `${list}/attachments/${attachmentFilename}`

    if (fs.existsSync(`src/${attachmentPath}`)) {
        fs.appendFileSync(topicPage, `
            <div style='${ATTACHMENT_STYLE}'>
                <a target=_blank href=attachments/${attachmentFilename}>
                    ${attachmentFilename}
                </a>
            </div>
        `)
        fs.copyFileSync(`src/${attachmentPath}`, `dist/${attachmentPath}`)
    }
}

const writeListHtml = list => {
    const listPage = `dist/${list}/index.html`
    fs.appendFileSync(listPage, `<a href='/'>back to root</a>`)
    fs.appendFileSync(listPage, `<h1>${list}</h1>`)

    parsed[list] && Object.entries(parsed[list]).forEach(([listTopicId, elements]) => {
        const listTopicPageFile = `topicId_${listTopicId}.html`
        const listTopicPage = `dist/${list}/${listTopicPageFile}`

        let initialElement = elements.find(el => el.previousId === 0)
        if (!initialElement) {
            elements.sort((a, b) => a.id > b.id ? 1 : -1)
            initialElement = elements[0]
        }

        const ids = elements.map(el => el.id).sort()

        const topicName = initialElement.email.subject
        fs.appendFileSync(listTopicPage, `<a href="/${list}">back to list</a>`)
        fs.appendFileSync(listTopicPage, `<h1>${topicName}</h1>`)

        fs.appendFileSync(listPage, `
            <div style="border-bottom: 1px solid lightgrey;">
                <div style="width: 80px; display: inline-block;">${initialElement.date}</div>
                <div style="width: 640px; display: inline-block;"><a href=${listTopicPageFile}>${topicName}</a></div>
                <div style="width: 120px; display: inline-block;">${elements.length} Message${elements.length > 1 ? 's' : ''}</div>
                <div style="width: 400px; display: inline-block;">${he.encode([...new Set(elements.map(el => el.email.from.text))].join(', '))}</div>
            </div>
        `)

        let element = initialElement
        while (element) {
            const {email: {attachments, textAsHtml, from}, nextId, date, time, id} = element

            fs.appendFileSync(listTopicPage, `<h3><a id=${id} href="#${id}">🔗</a>${he.encode(from.text)}</h3>`)
            fs.appendFileSync(listTopicPage, `<span>${date} ${time}</span>`)

            if (attachments.length) {
                fs.appendFileSync(listTopicPage, `<div style='${ATTACHMENT_STYLE}'><b>Attachments</b></div>`)
                attachments.forEach(attachment => writeAttachmentHtml(attachment, list, listTopicPage))
            }

            let textAsHtmlWithLinksUpdate = textAsHtml
                .replace(/http:\/\/users\.bigpond\.net\.au\/d\.keenan/g, 'http://dkeenan.com')

            const internalLinkRegexp = /http:\/\/groups\.yahoo\.com\/group\/(?<otherList>\w+)\/message\/(?<otherMsgId>\d+)/

            let matches = internalLinkRegexp.exec(textAsHtmlWithLinksUpdate)
            while (!!matches) {
                const otherList = matches.groups['otherList']
                const otherMsgId = matches.groups['otherMsgId']
                const otherTopicId = listMsgIdToTopicIdMap[otherList][otherMsgId]

                textAsHtmlWithLinksUpdate = textAsHtmlWithLinksUpdate.replace(
                    /http:\/\/groups\.yahoo\.com\/group\/\w+\/message\/\d+/,
                    `/${otherList}/topicId_${otherTopicId}.html#${otherMsgId}`,
                )

                matches = internalLinkRegexp.exec(textAsHtmlWithLinksUpdate)
            }

            fs.appendFileSync(listTopicPage, `<div style='${EMAIL_TEXT_STYLE}'>${textAsHtmlWithLinksUpdate}</div>`)

            element = elements.find(el => el.id === nextId)

            if (!element && nextId !== 0) {
                const altNextId = ids[ids.indexOf(id) + 1]
                element = elements.find(el => el.id === altNextId)
            }
        }
    })
}

const parseList = list => {
    fs.mkdirSync(`dist/${list}`)
    fs.mkdirSync(`dist/${list}/attachments`)

    setupPage(list)
    fs.appendFileSync(ROOT_PAGE, `<h3><a href=${list}>${list}</a></h3>\n`)

    if (list === 'old-tuning-list') {
        parseOldTuningList()
        return
    }

    let processedMessageCount = 0
    let messageCount = 0

    fs.readdirSync(`src/${list}/messages`).forEach(messagesFilename => {
        const messagesFile = JSON.parse(fs.readFileSync(`src/${list}/messages/${messagesFilename}`))

        messageCount += messagesFile.length

        messagesFile.forEach(async message => {
            const {topicId, rawEmail, prevInTopic, nextInTopic, msgId, postDate} = message

            if (!rawEmail) {
                processedMessageCount += 1
                if (processedMessageCount === messageCount) writeListHtml(list)
                return
            }

            const email = await simpleParser(he.decode(rawEmail))

            const datetime = new Date(postDate * 1000)

            if (!parsed[list]) parsed[list] = {}
            if (!parsed[list][topicId]) parsed[list][topicId] = []
            parsed[list][topicId].push({
                email,
                date: datetime.toLocaleDateString('en-US'),
                time: datetime.toLocaleTimeString('en-US'),
                previousId: prevInTopic,
                nextId: nextInTopic,
                id: msgId,
            })

            if (!listMsgIdToTopicIdMap[list]) listMsgIdToTopicIdMap[list] = {}
            listMsgIdToTopicIdMap[list][msgId] = topicId

            processedMessageCount += 1
            if (processedMessageCount === messageCount) writeListHtml(list)
        })
    })
}

const setupPage = (list) => {
    const header = `<!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
            <meta name="viewport"
        content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
            <meta http-equiv="x-ua-compatible" content="ie=edge">
            <title>Yahoo Tuning Groups Ultimate Backup ${list || 'Root'}</title>
        </head>
        <body>
        </body>
        </html>
    `
    fs.appendFileSync(`dist/${list ? `${list}/` : '/'}index.html`, header)
}

const parseOldTuningList = () => {
    const list = 'old-tuning-list'

    const subjects = []

    fs.readdirSync(`src/old-tuning-list`).forEach(messageFile => {
        const message = fs.readFileSync(`src/old-tuning-list/${messageFile}`).toString().split('\n')
        const datetime = new Date(message[1].replace('Date: ', ''))
        const subject = message[3].replace('Subject: ', '').replace('Re: ', '')
        const from = message[5].replace('From: ', '')
        const textAsHtml = message.slice(7).join('<br>')
        const topicId = subjects.indexOf(subject) === -1 ? subjects.push(subject) && subjects.length : subjects.indexOf(subject)

        if (!parsed[list]) parsed[list] = {}
        if (!parsed[list][topicId]) parsed[list][topicId] = []
        let id = parseInt(messageFile.replace('msg____', ''), 10)

        parsed[list][topicId].push({
            email: {
                attachments: [],
                textAsHtml,
                from: {
                    text: from,
                },
                subject,
            },
            date: datetime.toLocaleDateString('en-US'),
            time: datetime.toLocaleTimeString('en-US'),
            previousId: id - 1,
            nextId: id + 1,
            id,
        })
    })

    writeListHtml(list)
}

deleteFolderRecursive('dist')
fs.mkdirSync('dist')

setupPage()
fs.appendFileSync(ROOT_PAGE, `<h1>Yahoo Tuning Groups Ultimate Backup</h1>`)

fs.readdir(`src`, (err, lists) => lists.forEach(parseList))
