const {test} = require('node:test')
const assert = require('node:assert/strict')
const {MESSAGE_TEXT_CLASS, monospaceControlHtml, monospaceScriptHtml} = require('../monospace')

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

test('monospaceControlHtml renders a checkbox that starts checked', () => {
    const control = monospaceControlHtml()
    assert.match(control, /<input [^>]*type="checkbox"[^>]*>/)
    assert.match(control, /<input [^>]*checked[^>]*>/)
    assert.match(control, /monospace<\/label>/)
    assert.doesNotMatch(control, /<button/)
})

// Styles the whole message body, not its paragraphs: the mills list messages are
// joined with <br> and have no <p> at all.
const BODY = `.${MESSAGE_TEXT_CLASS}`

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
