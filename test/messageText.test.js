const {test} = require('node:test')
const assert = require('node:assert/strict')
const {messageTextHtml} = require('../messageText')

test('messageTextHtml wraps the message in a class-only box', () => {
    // Spelled out rather than shared with the module: this class is the one
    // end of the archive.css / archive.js / page contract that a redeploy of
    // the two files cannot reach, since it is written into 36,000-odd pages at
    // parse time. Read from the module, the assertion would agree with any
    // rename and the pages would quietly lose their styling and controls.
    const html = messageTextHtml('<p>a message</p>')
    assert.equal(html, '<div class="message-text"><p>a message</p></div>')
})

test('it carries no inline styling, so a redeploy of the stylesheet can restyle it', () => {
    // The whole point of the split: presentation lives in static/archive.css,
    // and changing it never means regenerating the archive's pages.
    assert.doesNotMatch(messageTextHtml('a message'), /style=/)
})
