const {test} = require('node:test')
const assert = require('node:assert/strict')
const {formatResult, messageUrl} = require('../search/format')

test('messageUrl points at the online backup message redirect page', () => {
    assert.equal(
        messageUrl('tuning-math', 1),
        'https://yahootuninggroupsultimatebackup.github.io/tuning-math/message/1.html',
    )
})

test('formatResult renders date, list, id, author, subject, snippet, and url', () => {
    const text = formatResult({
        list: 'tuning-math',
        msgId: 1,
        topicId: 1,
        postDate: 990420885,
        author: 'paul@stretch-music.com',
        subject: 'Hypothesis',
        snippet: 'Search for [hypothesis].',
    })

    assert.equal(text, [
        '2001-05-21  tuning-math #1  paul@stretch-music.com',
        '  Hypothesis',
        '  Search for [hypothesis].',
        '  https://yahootuninggroupsultimatebackup.github.io/tuning-math/message/1.html',
    ].join('\n'))
})

test('formatResult tolerates a missing date', () => {
    const text = formatResult({
        list: 'mills-tuning-list',
        msgId: 2000,
        topicId: null,
        postDate: null,
        author: 'Gary Morrison',
        subject: 'Note Doubling',
        snippet: '[doubling] notes',
    })

    assert.match(text, /^\?\?\?\?-\?\?-\?\?  mills-tuning-list #2000  Gary Morrison/)
})
