const fs = require('fs')
const path = require('path')
const he = require('he')
const {simpleParser} = require('mailparser')

const ROOT_PAGE = 'dist/index.html'
const HOST_SITE = 'https://yahootuninggroupsultimatebackup.github.io'

const ATTACHMENT_STYLE = 'margin: 0px 20px; padding: 20px; background-color: #ddd'
const EMAIL_TEXT_STYLE = 'margin: 0px 20px 20px; padding: 20px; background-color: #eee'

const parsed = {}

const common_words = [
'a', 'ability', 'able', 'about', 'above', 'accept', 'according', 'account', 'across', 'act', 'action', 'activity', 'actually', 'add', 'address', 'administration', 'admit', 'adult', 'affect', 'after', 'again', 'against', 'age', 'agency', 'agent', 'ago', 'agree', 'agreement', 'ahead', 'air', 'all', 'allow', 'almost', 'alone', 'along', 'already', 'also', 'although', 'always', 'among', 'amount', 'and', 'animal', 'another', 'answer', 'any', 'anyone', 'anything', 'appear', 'apply', 'approach', 'argue', 'arm', 'around', 'arrive', 'art', 'article', 'artist', 'as', 'ask', 'assume', 'at', 'attack', 'attention', 'attorney', 'audience', 'author', 'authority', 'available', 'avoid', 'away', 'baby', 'back', 'bad', 'bag', 'ball', 'bank', 'bar', 'base', 'be', 'beat', 'beautiful', 'because', 'become', 'bed', 'before', 'begin', 'behavior', 'behind', 'believe', 'benefit', 'best', 'better', 'between', 'beyond', 'big', 'bill', 'billion', 'bit', 'black', 'blood', 'blue', 'board', 'body', 'book', 'born', 'both', 'box', 'boy', 'break', 'bring', 'brother', 'budget', 'build', 'building', 'business', 'but', 'buy', 'by', 'call', 'camera', 'campaign', 'can', 'cancer', 'candidate', 'capital', 'car', 'card', 'care', 'career', 'carry', 'case', 'catch', 'cause', 'cell', 'center', 'central', 'century', 'certain', 'certainly', 'chair', 'challenge', 'chance', 'change', 'charge', 'check', 'child', 'choice', 'choose', 'church', 'citizen', 'city', 'civil', 'claim', 'class', 'clear', 'clearly', 'close', 'coach', 'cold', 'college', 'color', 'come', 'commercial', 'common', 'community', 'company', 'compare', 'computer', 'concern', 'condition', 'conference', 'Congress', 'consider', 'consumer', 'contain', 'continue', 'control', 'cost', 'could', 'country', 'couple', 'course', 'court', 'cover', 'create', 'crime', 'cultural', 'culture', 'cup', 'current', 'customer', 'cut', 'dark', 'data', 'daughter', 'day', 'dead', 'deal', 'death', 'debate', 'decade', 'decide', 'decision', 'deep', 'defense', 'degree', 'Democrat', 'democratic', 'describe', 'design', 'despite', 'detail', 'determine', 'develop', 'development', 'die', 'difference', 'different', 'difficult', 'dinner', 'director', 'discuss', 'discussion', 'disease', 'do', 'doctor', 'dog', 'door', 'down', 'draw', 'dream', 'drive', 'drop', 'drug', 'during', 'each', 'early', 'east', 'easy', 'eat', 'economic', 'economy', 'edge', 'education', 'effect', 'effort', 'either', 'election', 'else', 'employee', 'end', 'energy', 'enjoy', 'enough', 'enter', 'entire', 'environment', 'environmental', 'especially', 'establish', 'even', 'evening', 'event', 'ever', 'every', 'everybody', 'everyone', 'everything', 'evidence', 'exactly', 'executive', 'exist', 'expect', 'experience', 'expert', 'explain', 'eye', 'face', 'fact', 'factor', 'fail', 'fall', 'family', 'far', 'fast', 'father', 'fear', 'federal', 'feel', 'feeling', 'few', 'field', 'fight', 'figure', 'fill', 'film', 'finally', 'financial', 'find', 'fine', 'finger', 'finish', 'fire', 'firm', 'first', 'fish', 'floor', 'fly', 'focus', 'follow', 'food', 'foot', 'for', 'force', 'foreign', 'forget', 'form', 'former', 'forward', 'free', 'friend', 'from', 'front', 'full', 'fund', 'future', 'game', 'garden', 'gas', 'general', 'generation', 'get', 'girl', 'give', 'glass', 'go', 'goal', 'good', 'government', 'great', 'green', 'ground', 'group', 'grow', 'growth', 'guess', 'gun', 'guy', 'hair', 'half', 'hand', 'hang', 'happen', 'happy', 'hard', 'have', 'he', 'head', 'health', 'hear', 'heart', 'heat', 'heavy', 'help', 'her', 'here', 'herself', 'high', 'him', 'himself', 'his', 'history', 'hit', 'hold', 'home', 'hope', 'hospital', 'hot', 'hotel', 'hour', 'house', 'how', 'however', 'huge', 'human', 'hundred', 'husband', 'I', 'idea', 'identify', 'if', 'image', 'imagine', 'impact', 'in', 'including', 'increase', 'indeed', 'indicate', 'individual', 'industry', 'information', 'inside', 'instead', 'institution', 'interest', 'interesting', 'international', 'interview', 'into', 'investment', 'involve', 'issue', 'it', 'item', 'its', 'itself', 'job', 'join', 'keep', 'key', 'kid', 'kill', 'kind', 'kitchen', 'know', 'knowledge', 'land', 'large', 'last', 'late', 'later', 'laugh', 'law', 'lawyer', 'lay', 'lead', 'leader', 'learn', 'least', 'leave', 'left', 'leg', 'legal', 'less', 'let', 'letter', 'level', 'lie', 'life', 'light', 'like', 'line', 'list', 'listen', 'little', 'live', 'local', 'look', 'lose', 'loss', 'lot', 'love', 'low', 'machine', 'magazine', 'maintain', 'major', 'majority', 'make', 'man', 'manage', 'management', 'manager', 'many', 'market', 'marriage', 'material', 'matter', 'may', 'maybe', 'me', 'mean', 'measure', 'media', 'medical', 'meet', 'meeting', 'member', 'memory', 'mention', 'message', 'method', 'middle', 'might', 'military', 'mind', 'minute', 'miss', 'mission', 'modern', 'moment', 'money', 'month', 'more', 'morning', 'most', 'mother', 'mouth', 'move', 'movement', 'movie', 'Mr', 'Mrs', 'much', 'must', 'my', 'myself', 'name', 'nation', 'national', 'natural', 'nature', 'near', 'nearly', 'necessary', 'need', 'network', 'never', 'news', 'newspaper', 'next', 'nice', 'night', 'no', 'none', 'nor', 'north', 'not', 'nothing', 'notice', 'now', 'not', 'number', 'occur', 'of', 'off', 'offer', 'office', 'officer', 'official', 'often', 'oh', 'oil', 'ok', 'old', 'on', 'once', 'only', 'onto', 'open', 'operation', 'opportunity', 'option', 'or', 'order', 'organization', 'other', 'others', 'our', 'out', 'outside', 'over', 'own', 'owner', 'page', 'pain', 'painting', 'paper', 'parent', 'part', 'participant', 'particular', 'particularly', 'partner', 'party', 'pass', 'past', 'patient', 'pay', 'peace', 'people', 'per', 'perform', 'performance', 'perhaps', 'period', 'person', 'personal', 'phone', 'physical', 'pick', 'picture', 'piece', 'place', 'plan', 'plant', 'play', 'player', 'PM', 'point', 'police', 'policy', 'political', 'politics', 'poor', 'popular', 'population', 'position', 'positive', 'possible', 'power', 'practice', 'prepare', 'present', 'president', 'pressure', 'pretty', 'prevent', 'price', 'private', 'probably', 'produce', 'product', 'production', 'professional', 'professor', 'program', 'project', 'property', 'protect', 'prove', 'provide', 'public', 'pull', 'purpose', 'push', 'put', 'quality', 'question', 'quickly', 'quite', 'race', 'radio', 'raise', 'range', 'rate', 'rather', 'reach', 'read', 'ready', 'real', 'reality', 'realize', 'really', 'reason', 'receive', 'recent', 'recently', 'recognize', 'record', 'red', 'reduce', 'reflect', 'region', 'relate', 'religious', 'remain', 'remember', 'remove', 'report', 'Republican', 'require', 'research', 'resource', 'respond', 'response', 'responsibility', 'rest', 'result', 'return', 'reveal', 'rich', 'right', 'rise', 'risk', 'road', 'rock', 'role', 'room', 'rule', 'run', 'safe', 'save', 'say', 'scene', 'school', 'science', 'scientist', 'score', 'sea', 'season', 'seat', 'second', 'section', 'security', 'see', 'seek', 'seem', 'sell', 'send', 'senior', 'sense', 'series', 'serious', 'serve', 'service', 'set', 'several', 'sex', 'sexual', 'shake', 'share', 'she', 'shoot', 'short', 'shot', 'should', 'shoulder', 'show', 'side', 'sign', 'significant', 'similar', 'simple', 'simply', 'since', 'sing', 'single', 'sister', 'sit', 'site', 'situation', 'size', 'skill', 'skin', 'small', 'smile', 'so', 'social', 'society', 'soldier', 'some', 'somebody', 'someone', 'something', 'sometimes', 'son', 'soon', 'sort', 'source', 'south', 'southern', 'space', 'speak', 'speech', 'spend', 'sport', 'spring', 'staff', 'stage', 'stand', 'standard', 'star', 'start', 'state', 'statement', 'station', 'stay', 'step', 'still', 'stock', 'stop', 'store', 'story', 'strategy', 'street', 'strong', 'student', 'study', 'stuff', 'style', 'subject', 'success', 'successful', 'such', 'suddenly', 'suffer', 'suggest', 'summer', 'support', 'sure', 'surface', 'table', 'take', 'talk', 'task', 'tax', 'teach', 'teacher', 'team', 'technology', 'television', 'tell', 'tend', 'term', 'than', 'thank', 'that', 'the', 'their', 'them', 'themselves', 'then', 'there', 'these', 'they', 'thing', 'think', 'third', 'this', 'those', 'though', 'thought', 'thousand', 'threat', 'through', 'throughout', 'throw', 'thus', 'time', 'to', 'today', 'together', 'tonight', 'too', 'top', 'total', 'tough', 'toward', 'town', 'trade', 'training', 'travel', 'treat', 'treatment', 'tree', 'trial', 'trip', 'trouble', 'true', 'truth', 'try', 'turn', 'TV', 'type', 'under', 'understand', 'until', 'up', 'upon', 'us', 'use', 'usually', 'value', 'various', 'very', 'victim', 'view', 'violence', 'visit', 'voice', 'vote', 'wait', 'walk', 'wall', 'want', 'war', 'watch', 'water', 'way', 'we', 'weapon', 'wear', 'week', 'weight', 'well', 'west', 'what', 'whatever', 'when', 'where', 'whether', 'which', 'while', 'white', 'who', 'whole', 'whom', 'whose', 'why', 'wide', 'wife', 'will', 'win', 'wind', 'window', 'wish', 'with', 'within', 'without', 'woman', 'wonder', 'word', 'work', 'worker', 'world', 'worry', 'would', 'write', 'writer', 'wrong', 'yard', 'yeah', 'year', 'yes', 'yet', 'you', 'young', 'your', 'yourself'
]

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

const distinct = (value, index, self) => self.indexOf(value) === index

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
        ).split(/[\s;,]+/).filter(distinct).filter(word => !common_words.includes(word)).join(' ')

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
