// Builds two real topic pages into dist/, so the reader's controls can be
// judged on real archive material rather than a mock. Both pages are the one
// writeListHtml() writes — same header, same search bar, same messageTextHtml()
// around each body, same parse of the source. Only the two asset links differ:
// relative here rather than rooted at /, so a page opens by double-click with
// no server behind it.
//
// The two are the archive's two shapes, which is also the two ways a message
// can open. Graham Breed's "Magic lattices" is a Yahoo-list topic,
// hard-wrapped at about 72 columns by the mail client of the era, carrying
// lattices 25 lines deep — no line reaches 75 columns, so every message opens
// unfolded, nothing overflows a wide window, and narrowing one is where the
// fold would cost a diagram. Dave Keenan and Paul Erlich on a strange 9-limit
// temperament come from the Mills list, whose prose was never wrapped at all:
// two of the three run to 484 and 464 columns and open folded with the box
// already checked, around a tab-aligned table and a lattice of 7-limit
// tetrahedra — while the short reply between them wraps at 72 like a Yahoo
// post and opens unfolded beside them.
const fs = require('fs')
const path = require('path')
const he = require('he')
const {simpleParser} = require('mailparser')
const {searchBarHtml} = require('../search/searchBar')
const {messageTextHtml} = require('../messageText')

// Rooted at the checkout rather than at the shell's cwd, like the search demo
// beside it, and building the dist/ a fresh checkout does not have: dist/ is
// gitignored down to the last file.
const ROOT = path.join(__dirname, '..')
const DIST = path.join(ROOT, 'dist')

const ARCHIVE_ASSETS = `<link rel="stylesheet" href="archive.css"><script src="archive.js" defer></script>`

fs.mkdirSync(DIST, {recursive: true})
;['archive.css', 'archive.js'].forEach(file =>
    fs.copyFileSync(path.join(ROOT, 'static', file), path.join(DIST, file)))

const millsMessages = messageFiles => messageFiles.map(messageFile => {
    const message = fs.readFileSync(path.join(ROOT, 'src', 'mills-tuning-list', messageFile)).toString().split('\n')
    const datetime = new Date(message[1].replace('Date: ', ''))

    return {
        datetime,
        subject: message[3].replace('Subject: ', '').replace('Re: ', ''),
        from: message[5].replace('From: ', '').replace(/<(\S+)@\S+>/, '<$1@...>'),
        textAsHtml: message.slice(7).join('<br>'),
        id: parseInt(messageFile.replace('msg____', ''), 10),
    }
})

const yahooMessages = async (list, topicId) => {
    const messages = []

    const directory = path.join(ROOT, 'src', list, 'messages')

    for (const file of fs.readdirSync(directory)) {
        for (const message of JSON.parse(fs.readFileSync(path.join(directory, file)))) {
            if (message.topicId !== topicId || !message.rawEmail) continue

            const email = await simpleParser(he.decode(message.rawEmail))
            messages.push({
                datetime: new Date(message.postDate * 1000),
                subject: email.subject,
                from: email.from.text,
                textAsHtml: email.textAsHtml,
                id: message.msgId,
            })
        }
    }

    return messages.sort((a, b) => a.id - b.id)
}

const writePage = (page, list, messages) => {
    const topicName = messages[0].subject

    fs.writeFileSync(page, `<!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
            <meta name="viewport"
        content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
            <meta http-equiv="x-ua-compatible" content="ie=edge">
            <title>Yahoo Tuning Groups Ultimate Backup ${list} ${topicName}</title>
            ${ARCHIVE_ASSETS}
        </head>
        <body>
        </body>
        </html>
    `)

    fs.appendFileSync(page, searchBarHtml({list}))
    fs.appendFileSync(page, `<a href="/${list}">back to list</a>`)
    fs.appendFileSync(page, `<h1>${topicName}</h1>`)

    messages.forEach(({datetime, from, textAsHtml, id}) => {
        fs.appendFileSync(page, `<h3><a id=${id} href="#${id}">🔗</a>${he.encode(from)}</h3>`)
        fs.appendFileSync(page, `<span>${datetime.toLocaleDateString('en-US')} ${datetime.toLocaleTimeString('en-US')}</span>`)
        fs.appendFileSync(page, messageTextHtml(textAsHtml))
    })

    console.log(`wrote ${page} — ${messages.length} messages of "${topicName}"`)
}

const run = async () => {
    writePage(path.join(DIST, 'demo-mills-tuning-list.html'), 'mills-tuning-list',
        millsMessages(['msg____8827.txt', 'msg____8830.txt', 'msg____8863.txt']))

    writePage(path.join(DIST, 'demo-tuning-math.html'), 'tuning-math',
        await yahooMessages('tuning-math', 586))
}

run()
