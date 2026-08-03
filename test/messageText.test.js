const {test} = require('node:test')
const assert = require('node:assert/strict')
const {MESSAGE_TEXT_CLASS, messageTextHtml, monospaceControlHtml, monospaceScriptHtml} = require('../messageText')

// Runs the generated script against a jQuery stub that records every call, so the
// test exercises the real behavior rather than matching source text.
const runScript = () => {
    const calls = []
    const handlers = []
    const $ = selector => ({
        css: (name, value) => calls.push([selector, name, value]),
        prop: (name, value) => calls.push([selector, name, value]),
        on: (event, handler) => handlers.push([event, handler]),
    })
    const body = monospaceScriptHtml().replace(/[\s\S]*<script>/, '').replace(/<\/script>[\s\S]*/, '')
    new Function('$', body)($)

    return {calls, handlers}
}

// Styles the whole message body, not its paragraphs: the mills list messages are
// joined with <br> and have no <p> at all.
const BODY = `.${MESSAGE_TEXT_CLASS}`

test('messageTextHtml wraps the message in its own styled box', () => {
    const html = messageTextHtml('<p>a message</p>')
    assert.match(html, new RegExp(`^<div class='${MESSAGE_TEXT_CLASS}' style='[^']*'><p>a message</p></div>$`))
    assert.match(html, /margin: 0px 20px 20px/)
    assert.match(html, /padding: 20px/)
    assert.match(html, /background-color: #eee/)
})

test('the message box pins its own font metrics, so swapping fonts cannot resize it', () => {
    // Both are needed to keep a message the same height in either font: browsers
    // render a generic monospace family a few pixels smaller than everything
    // else, and a line-height of normal is derived from the font in play.
    const html = messageTextHtml('a message')
    assert.match(html, /font-size: 16px/)
    // 16px monospace advances 9.6px per character, so this leading keeps a
    // character cell at the roughly 2:1 the ASCII lattice diagrams were drawn
    // for. Looser leading stretches them and steepens every diagonal.
    assert.match(html, /line-height: 1\.2/)
})

test('the message box keeps the spacing the author typed', () => {
    // Runs of spaces are what hold an ASCII lattice together, and HTML collapses
    // them by default. The generated markup has no newlines of its own, so
    // pre-wrap costs nothing: line breaks still come from the <br> tags.
    assert.match(messageTextHtml('a message'), /white-space: pre-wrap/)
})

test('monospaceControlHtml renders a checkbox that starts checked', () => {
    const control = monospaceControlHtml()
    assert.match(control, /<input [^>]*type="checkbox"[^>]*>/)
    assert.match(control, /<input [^>]*checked[^>]*>/)
    assert.match(control, /monospace<\/label>/)
    assert.doesNotMatch(control, /<button/)
})

test('the script starts the page monospaced', () => {
    const {calls} = runScript()
    assert.deepEqual(calls, [['.monospace', 'checked', true], [BODY, 'font-family', 'monospace']])
})

test('unchecking any checkbox unstyles the page and syncs the other checkboxes', () => {
    const {calls, handlers} = runScript()
    calls.length = 0

    const [[event, handler]] = handlers
    assert.equal(event, 'change')

    handler.call({checked: false})
    assert.deepEqual(calls, [['.monospace', 'checked', false], [BODY, 'font-family', '']])

    calls.length = 0
    handler.call({checked: true})
    assert.deepEqual(calls, [['.monospace', 'checked', true], [BODY, 'font-family', 'monospace']])
})
