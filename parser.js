const fs = require('fs')
const path = require('path')
const he = require('he')
const {simpleParser} = require('mailparser')

const ROOT_PAGE = 'dist/index.html'
const HOST_SITE = 'https://yahootuninggroupsultimatebackup.github.io'

const ATTACHMENT_STYLE = 'margin: 0px 20px; padding: 20px; background-color: #ddd'
const EMAIL_TEXT_STYLE = 'margin: 0px 20px 20px; padding: 20px; background-color: #eee'

const parsed = {}

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

        const initialElement = elements.find(el => el.previousId === 0)
        if (!initialElement) {
            console.log('topic with no first element?', elements.map(({id, nextId, previousId}) => ({
                id,
                nextId,
                previousId,
            })))

            return
        }

        const topicName = initialElement.email.subject
        fs.appendFileSync(listTopicPage, `<a href="/${list}">back to list</a>`)
        fs.appendFileSync(listTopicPage, `<h1>${topicName}</h1>`)

        let allTopicText = elements.reduce(
            (textSoFar, el) => {
                return `${textSoFar} ${he.encode(el.email.from.text)} ${el.email.text}`
            },
            '',
        )
        const text = `${topicName} ${allTopicText}`
        const searchObject = {
            title: topicName,
            text,
            url: `${HOST_SITE}/${list}/${listTopicPageFile}`
        }
        fs.appendFileSync('dist/tipuesearch/tipuesearch_content.js', `${JSON.stringify(searchObject)},\n`)

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
            const {email: {attachments, textAsHtml, from}, nextId, date, time} = element

            fs.appendFileSync(listTopicPage, `<h3>${he.encode(from.text)}</h3>`)
            fs.appendFileSync(listTopicPage, `<span>${date} ${time}</span>`)

            if (attachments.length) {
                fs.appendFileSync(listTopicPage, `<div style='${ATTACHMENT_STYLE}'><b>Attachments</b></div>`)
                attachments.forEach(attachment => writeAttachmentHtml(attachment, list, listTopicPage))
            }

            fs.appendFileSync(listTopicPage, `<div style='${EMAIL_TEXT_STYLE}'>${textAsHtml}</div>`)

            element = elements.find(el => el.id === nextId)
        }
    })
}

const parseList = list => {
    fs.mkdirSync(`dist/${list}`)
    fs.mkdirSync(`dist/${list}/attachments`)

    setupPage(list)
    fs.appendFileSync(ROOT_PAGE, `<h3><a href=${list}>${list}</a></h3>\n`)

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

            processedMessageCount += 1
            if (processedMessageCount === messageCount) writeListHtml(list)
        })
    })
}

const setupPage = (list, topicName) => {
    const header = `<!DOCTYPE html>
        <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
                <meta http-equiv="x-ua-compatible" content="ie=edge">
                <title>Yahoo Tuning Groups Ultimate Backup ${list ? ` - ${list}` : ''} ${topicName ? ` - ${topicName}` : ''}</title>
                <link rel="stylesheet" href="tipuesearch/tipuesearch.css" type="text/css" >
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
                <script src="tipuesearch/tipuesearch_content.js"></script>
                <script src="tipuesearch/tipuesearch_set.js"></script>
                <script src="tipuesearch/tipuesearch.min.js"></script>
            </head>
            <body>
            </body>
        </html>
        
        ${list ? '' : `<form>
            <div class="tipue_search_group">
                <input type="text" name="q" id="tipue_search_input" pattern=".{3,}" title="At least 3 characters" required>
                <button type="submit" class="tipue_search_button">
                    <div class="tipue_search_icon">&#9906;</div>
                </button>
            </div>
        </form>
        
        <div id="tipue_search_content"></div>
        
        <script>
            $('#tipue_search_input').tipuesearch()
        </script>`}
    `
    fs.appendFileSync(`dist/${list ? `${list}/` : '/'}index.html`, header)
}

const copyFileSync = (source, target) => {
    let targetFile = target

    if (fs.existsSync(target) && fs.lstatSync(target).isDirectory()) {
        targetFile = path.join(target, path.basename(source))
    }

    fs.writeFileSync(targetFile, fs.readFileSync(source))
}

const copyFolderRecursiveSync = (source, target) => {
    let targetFolder = path.join(target, path.basename(source))
    if (!fs.existsSync(targetFolder)) {
        fs.mkdirSync(targetFolder)
    }

    if (fs.lstatSync(source).isDirectory()) {
        fs.readdirSync(source).forEach(file => {
            const curSource = path.join(source, file)
            if (fs.lstatSync(curSource).isDirectory()) {
                copyFolderRecursiveSync(curSource, targetFolder)
            } else {
                copyFileSync(curSource, targetFolder)
            }
        })
    }
}

deleteFolderRecursive('dist')
fs.mkdirSync('dist')

fs.mkdirSync('dist/tipuesearch')
copyFolderRecursiveSync('vendor/tipuesearch', 'dist')

setupPage()
fs.appendFileSync('dist/tipuesearch/tipuesearch_content.js', `var tipuesearch = {"pages": [\n`)
fs.appendFileSync(ROOT_PAGE, `<h1>Yahoo Tuning Groups Ultimate Backup</h1>`)

fs.readdir(`src`, (err, lists) => lists.forEach(parseList))
