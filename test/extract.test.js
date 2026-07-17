const {test} = require('node:test')
const assert = require('node:assert/strict')
const {yahooMessageToDoc, millsFileToDoc} = require('../search/extract')

test('yahooMessageToDoc maps metadata and extracts entity-decoded plain-text body', async () => {
    const message = {
        authorName: 'paul@stretch-music.com',
        from: 'paul@stretch-music.com',
        subject: 'Hypothesis',
        postDate: '990420885',
        msgId: 1,
        topicId: 1,
        msgSnippet: 'No one responded to my Hypothesis.',
        rawEmail: 'Date: Mon, 21 May 2001 04:54:45 -0000\n' +
            'To: tuning-math@yahoogroups.com\n' +
            'Subject: Hypothesis\n' +
            'Message-ID: &lt;9ea72l+q1ps@eGroups.com&gt;\n' +
            'Content-Type: text/plain; charset=ISO-8859-1\n' +
            'From: paul@stretch-music.com\n' +
            '\n' +
            'No one responded to my Hypothesis. Search for &quot;hypothesis&quot;.',
    }

    const doc = await yahooMessageToDoc('tuning-math', message)

    assert.equal(doc.list, 'tuning-math')
    assert.equal(doc.msgId, 1)
    assert.equal(doc.topicId, 1)
    assert.equal(doc.postDate, 990420885)
    assert.equal(doc.author, 'paul@stretch-music.com')
    assert.equal(doc.subject, 'Hypothesis')
    assert.match(doc.body, /Search for "hypothesis"/)
})

test('yahooMessageToDoc decodes entities in the subject field', async () => {
    const message = {
        authorName: 'x@y.com',
        subject: 'commas &amp; kleismas',
        postDate: '5',
        msgId: 9,
        topicId: 2,
        rawEmail: 'Subject: commas\nFrom: x@y.com\n\nbody',
    }

    const doc = await yahooMessageToDoc('tuning', message)

    assert.equal(doc.subject, 'commas & kleismas')
    assert.equal(doc.postDate, 5)
})

test('millsFileToDoc parses header lines and body from the fixed-layout text format', () => {
    const content = 'source file: mills2.txt\n' +
        'Date: Sat, 16 Sep 1995 09:45:27 -0700\n' +
        '\n' +
        'Subject: 88CET #10:  Note Doubling\n' +
        '\n' +
        'From: Gary Morrison <71670.2576@compuserve.com>\n' +
        '\n' +
        'Probably the easiest way to extend a chord\n' +
        'is by doubling one or more notes.'

    const doc = millsFileToDoc('msg____2000.txt', content)

    assert.equal(doc.list, 'mills-tuning-list')
    assert.equal(doc.msgId, 2000)
    assert.equal(doc.topicId, null)
    assert.equal(doc.postDate, Date.parse('Sat, 16 Sep 1995 09:45:27 -0700') / 1000)
    assert.equal(doc.author, 'Gary Morrison <71670.2576@compuserve.com>')
    assert.equal(doc.subject, '88CET #10:  Note Doubling')
    assert.match(doc.body, /easiest way to extend/)
    assert.doesNotMatch(doc.body, /source file/)
})
