const {test} = require('node:test')
const assert = require('node:assert/strict')
const {MESSAGE_TEXT_CLASS, messageTextHtml, monospaceControlHtml} = require('../messageText')

test('messageTextHtml wraps the message in a class-only box', () => {
    const html = messageTextHtml('<p>a message</p>')
    assert.equal(html, `<div class="${MESSAGE_TEXT_CLASS}"><p>a message</p></div>`)
})

test('monospaceControlHtml renders a checkbox that starts checked', () => {
    const control = monospaceControlHtml()
    assert.match(control, /<input [^>]*type="checkbox"[^>]*>/)
    assert.match(control, /<input [^>]*checked[^>]*>/)
    assert.match(control, /monospace<\/label>/)
    assert.match(control, /class="monospace-control"/)
})

test('neither carries inline styling, so a redeploy of the stylesheet can restyle them', () => {
    // The whole point of the split: presentation lives in static/archive.css,
    // and changing it never means regenerating the archive's pages.
    assert.doesNotMatch(messageTextHtml('a message'), /style=/)
    assert.doesNotMatch(monospaceControlHtml(), /style=/)
})
