const fs = require('fs')
const he = require('he')
const pth = require('path')
const {simpleParser} = require('mailparser')

process.on('uncaughtException', console.log)

const ROOT_PAGE = 'dist/index.html'

const ATTACHMENT_STYLE = 'margin: 0px 20px; padding: 20px; background-color: #ddd'
const EMAIL_TEXT_STYLE = 'margin: 0px 20px 20px; padding: 20px; background-color: #eee'

const parsed = {}
const listMsgIdToTopicIdMap = {}
const listMessageCounts = {}

let processedListCount = 0
const totalListCount = 6

let writtenMessageCount = 0
let loggedWrittenMessageCount = 0

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
        const header = `<!DOCTYPE html>
            <html>
            <head>
            <meta charset="utf-8">
                <meta name="viewport"
            content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
                <meta http-equiv="x-ua-compatible" content="ie=edge">
                <title>Yahoo Tuning Groups Ultimate Backup ${list} ${topicName}</title>
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
            </head>
            <body>
            </body>
            </html>
        `
        fs.appendFileSync(listTopicPage, header)
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
        let seenIds = []
        while (element) {
            if (writtenMessageCount >= loggedWrittenMessageCount) {
                console.log('on list', list, 'wrote', loggedWrittenMessageCount, 'messages of total', listMessageCounts[list])
                loggedWrittenMessageCount += 5000
            }

            const {email: {attachments, textAsHtml, from}, nextId, date, time, id} = element
            seenIds.push(id)

            fs.appendFileSync(listTopicPage, `<h3><a id=${id} href="#${id}">🔗</a>${he.encode(from.text)}</h3>`)
            fs.appendFileSync(listTopicPage, `<span>${date} ${time}</span>`)
            fs.appendFileSync(listTopicPage, `<button style="float: right; margin-right: 20px">toggle monospace</button>`)

            if (attachments.length) {
                fs.appendFileSync(listTopicPage, `<div style='${ATTACHMENT_STYLE}'><b>Attachments</b></div>`)
                attachments.forEach(attachment => writeAttachmentHtml(attachment, list, listTopicPage))
            }

            let textAsHtmlWithLinksUpdate = (textAsHtml || '')
                .replace(/http:\/\/users\.bigpond\.net\.au\/d\.keenan/g, 'http://dkeenan.com')
                .replace(/http:\/\/uq\.net\.au\/~zzdkeena/g, 'http://dkeenan.com')
                .replace(/http:\/\/www\.ixpres\.com\/interval\/dict\/72edo\.htm/g, 'http://tonalsoft.com/enc/number/72edo.aspx')
                .replace(/http:\/\/www\.ixpres\.com\/interval\/dict\/qt-staff\.htm/g, 'http://tonalsoft.com/enc/q/qt-staff.aspx')
                .replace(/http:\/\/members\.tripod\.de\/EkmelischeMusik\//g, 'http://www.ekmelic-music.org/en/em/notation.htm')
                .replace(/http:\/\/www\.mindspring\.com\/~tmook\/micro\.html/g, 'https://www.mindeartheart.org/micro.html')
                .replace(/http:\/\/www\.microtonal\.co\.uk/g, 'http://x31eq.com')

            const internalLinkRegexp = /http:\/\/\w*\.?groups\.yahoo\.com\/group\/(?<otherList>\w+)\/messages?\/(?<otherMsgId>\d+)/

            let matches = internalLinkRegexp.exec(textAsHtmlWithLinksUpdate)
            while (!!matches) {
                const otherList = matches.groups['otherList'].toLowerCase()
                const otherMsgId = matches.groups['otherMsgId']
                const otherTopicId = listMsgIdToTopicIdMap[otherList] && listMsgIdToTopicIdMap[otherList][otherMsgId]

                if (otherTopicId) {
                    textAsHtmlWithLinksUpdate = textAsHtmlWithLinksUpdate.replace(
                        /http:\/\/\w*\.?groups\.yahoo\.com\/group\/\w+\/messages?\/\d+/,
                        `/${otherList}/topicId_${otherTopicId}.html#${otherMsgId}`,
                    )
                } else {
                    console.log('on list', list, 'topic id', listTopicId, 'doing msg id', id, 'when failed to fix link', matches[0], matches[1], matches[2], 'to its new internal location, perhaps because it had not been parsed yet; other list', otherList, 'other message id', otherMsgId, 'other topic id', otherTopicId)
                    textAsHtmlWithLinksUpdate = textAsHtmlWithLinksUpdate.replace(
                        /http:\/\/\w*\.?groups\.yahoo\.com\/group\/\w+\/messages?\/\d+/,
                        `/${otherList}/topicId_unknown.html#${otherMsgId}`,
                    )
                }

                matches = internalLinkRegexp.exec(textAsHtmlWithLinksUpdate)
            }

            const fileRegexp = /http:\/\/\w*\.?groups\.yahoo\.com\/group\/\w+\/files\/(?<filePath>[^\.]+\.(ASM|BAS|COM|EXE|GIF|HTM|JPG|LIB|MID|PDF|TXT|WAV|XLS|ZIP|aiff|bmp|csd|csv|dbg|djvu|doc|docx|exe|gif|gly|hqx|htm|html|jpeg|jpg|json|lisp|lsp|mid|mov|mp3|mpg|nb|nkp|nwc|ods|ogg|p5m|patch|pdf|plg|png|py|rar|rtf|scl|sco|score|seq|shs|svg|swp|tif|tonescape|tun|tuning|txt|wav|wma|xls|xlsx|zip|))/
            let fileMatches = fileRegexp.exec(textAsHtmlWithLinksUpdate)
            while (!!fileMatches) {
                const filePath = fileMatches.groups['filePath']
                console.log('looking for filePath', filePath)

                if (fs.existsSync(`src/${list}/files/${filePath}`)) {
                    console.log('found it!')
                    const dirname = pth.dirname(filePath)
                    fs.existsSync(`dist/${list}/files/${dirname}`) || fs.mkdirSync(`dist/${list}/files/${dirname}`, { recursive: true })

                    fs.copyFileSync(`src/${list}/files/${filePath}`, `dist/${list}/files/${filePath}`)
                }

                textAsHtmlWithLinksUpdate = textAsHtmlWithLinksUpdate.replace(
                  /http:\/\/\w*\.?groups\.yahoo\.com\/group\/\w+\/files\/[^\.]+\.(ASM|BAS|COM|EXE|GIF|HTM|JPG|LIB|MID|PDF|TXT|WAV|XLS|ZIP|aiff|bmp|csd|csv|dbg|djvu|doc|docx|exe|gif|gly|hqx|htm|html|jpeg|jpg|json|lisp|lsp|mid|mov|mp3|mpg|nb|nkp|nwc|ods|ogg|p5m|patch|pdf|plg|png|py|rar|rtf|scl|sco|score|seq|shs|svg|swp|tif|tonescape|tun|tuning|txt|wav|wma|xls|xlsx|zip|)/,
                  `/${list}/files/${filePath}`,
                )

                fileMatches = fileRegexp.exec(textAsHtmlWithLinksUpdate)
            }

            textAsHtmlWithLinksUpdate = textAsHtmlWithLinksUpdate.replace(/http:\/\/\w*\.?groups\.yahoo\.com\/group\/(\w+)/g, '/$1')
            textAsHtmlWithLinksUpdate = textAsHtmlWithLinksUpdate.replace(/\/MakeMicroMusic/g, '/makemicromusic')

            fs.appendFileSync(listTopicPage, `<div style='${EMAIL_TEXT_STYLE}'>${textAsHtmlWithLinksUpdate}</div>`)

            const listMessagePage = `dist/${list}/message/${id}.html`
            const listMessagesPage = `dist/${list}/messages/${id}.html`
            const redirect = `<meta http-equiv="Refresh" content="0; url='../${listTopicPageFile}#${id}'" />`

            fs.appendFileSync(listMessagePage, redirect)
            fs.appendFileSync(listMessagesPage, redirect)

            element = elements.find(el => el.id === nextId)

            if (!element && nextId !== 0) {
                const altNextId = ids[ids.indexOf(id) + 1]
                if (!seenIds.includes(altNextId)) {
                    element = elements.find(el => el.id === altNextId)
                } else {
                    console.log('found a loop in topic', listTopicId, 'where message id', id, 'was trying to go back to', altNextId, 'but in this topic we have already seen ids', seenIds.join(' '))
                }
            }

            writtenMessageCount += 1
        }

        fs.appendFileSync(
            listTopicPage,
            `
                <script>
                    let monospace = false
                    $('button').on('click', function () {
                      if (monospace) {
                        $('p').css("font-family", "")
                      } else {
                        $('p').css("font-family", "monospace")
                      }
                      monospace = !monospace
                    })
                </script>
            `
        )
    })
}

const writeAllHtml = () => {
    fs.readdir(`src`, (err, lists) => lists.forEach(list => list !== 'mills-tuning-list' && writeListHtml(list)))
}

const parseList = list => {
    fs.mkdirSync(`dist/${list}`)
    fs.mkdirSync(`dist/${list}/attachments`)
    fs.mkdirSync(`dist/${list}/files`)
    fs.mkdirSync(`dist/${list}/message`)
    fs.mkdirSync(`dist/${list}/messages`)

    setupPage(list)
    fs.appendFileSync(ROOT_PAGE, `<h3><a href=${list}>${list}</a></h3>\n`)

    listMessageCounts[list] = 0

    if (list === 'mills-tuning-list') {
        parseMillsTuningList()
        return
    }

    let processedMessageCount = 0
    let loggedProcessedMessageCount = 0

    fs.readdirSync(`src/${list}/messages`).forEach(messagesFilename => {
        const messagesFile = JSON.parse(fs.readFileSync(`src/${list}/messages/${messagesFilename}`))

        listMessageCounts[list] += messagesFile.length

        messagesFile.forEach(message => {
            const {topicId, rawEmail, prevInTopic, nextInTopic, msgId, postDate} = message

            if (!rawEmail) {
                processedMessageCount += 1
                if (processedMessageCount === listMessageCounts[list]) {
                    processedListCount += 1
                    console.log('in the sad path, having just finished processing list', list, 'we just incremented processed list count to', processedListCount)
                    if (processedListCount === totalListCount) {
                        console.log('we will now write HTML for the lists')
                        writeAllHtml()
                    }
                }
                return
            }

            simpleParser(he.decode(rawEmail)).then(email => {
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
                if (processedMessageCount === listMessageCounts[list]) {
                    processedListCount += 1
                    console.log('in the happy path, having just finished processing list', list, 'we just incremented processed list count to', processedListCount)
                    if (processedListCount === totalListCount) {
                        console.log('we will now write HTML for the lists')
                        writeAllHtml()
                    }
                }

                if (processedMessageCount >= loggedProcessedMessageCount) {
                    console.log('on list', list, 'processed', loggedProcessedMessageCount, 'messages of total', listMessageCounts[list])
                    loggedProcessedMessageCount += 5000
                }
            })
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

const parseMillsTuningList = () => {
    const list = 'mills-tuning-list'

    const subjects = []

    const millsTuningListMessageFiles = fs.readdirSync(`src/mills-tuning-list`)

    listMessageCounts[list] += millsTuningListMessageFiles.length

    let processedMessageCount = 0
    let loggedProcessedMessageCount = 0

    millsTuningListMessageFiles.forEach(messageFile => {
        const message = fs.readFileSync(`src/mills-tuning-list/${messageFile}`).toString().split('\n')
        const datetime = new Date(message[1].replace('Date: ', ''))
        const subject = message[3].replace('Subject: ', '').replace('Re: ', '')
        const from = message[5].replace('From: ', '').replace(/<(\S+)@\S+>/, '<$1@...>')
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

        processedMessageCount += 1
        if (processedMessageCount >= loggedProcessedMessageCount) {
            console.log('on list', list, 'processed', loggedProcessedMessageCount, 'messages of total', listMessageCounts[list])
            loggedProcessedMessageCount += 5000
        }
    })

    console.log('we will now write HTML for the mills-tuning-list')
    writeListHtml(list)
}

deleteFolderRecursive('dist')
fs.mkdirSync('dist')

setupPage()
fs.appendFileSync(ROOT_PAGE, `<h1>Yahoo Tuning Groups Ultimate Backup</h1>`)

fs.readdir(`src`, (err, lists) => lists.forEach(parseList))
