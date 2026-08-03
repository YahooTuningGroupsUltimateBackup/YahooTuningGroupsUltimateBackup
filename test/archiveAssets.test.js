const {test} = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')

const css = fs.readFileSync(path.join(__dirname, '..', 'static', 'archive.css'), 'utf8')
const script = fs.readFileSync(path.join(__dirname, '..', 'static', 'archive.js'), 'utf8')

// Stands in for the DOM of one topic page: a control label followed by the
// message body it governs, which is how the parser emits every message.
const pageWith = messages => {
    let listener
    const document = {addEventListener: (event, handler) => (listener = [event, handler])}
    const boxes = messages.map(() => ({classes: new Set(), classList: {toggle: function (name, on) {
        on ? this.owner.classes.add(name) : this.owner.classes.delete(name)
    }}}))
    boxes.forEach(box => (box.classList.owner = box))

    const checkboxes = boxes.map(box => ({
        checked: true,
        classList: {contains: name => name === 'monospace'},
        closest: () => ({nextElementSibling: box}),
    }))

    new Function('document', script)(document)

    return {boxes, checkboxes, fire: checkbox => listener[1]({target: checkbox}), event: () => listener[0]}
}

test('the stylesheet holds the presentation, so pages need no inline styles', () => {
    assert.match(css, /\.message-text\s*\{[^}]*font-family: monospace/)
    assert.match(css, /\.message-text\s*\{[^}]*font-size: 16px/)
    assert.match(css, /\.message-text\s*\{[^}]*line-height: 1\.2/)
    assert.match(css, /\.message-text\s*\{[^}]*white-space: pre-wrap/)
    assert.match(css, /\.message-text\.proportional\s*\{[^}]*font-family:/)
    assert.match(css, /\.monospace-control\s*\{[^}]*float: right/)
    assert.match(css, /\.search-bar\s*\{/)
    assert.match(css, /\.attachment\s*\{/)
})

test('a message starts monospaced with no script having run', () => {
    // The stylesheet alone decides the initial state, so pages render correctly
    // before — or without — any JavaScript: loading the script touches nothing.
    assert.doesNotMatch(script, /font-family/)
    const page = pageWith(['only'])
    assert.deepEqual([...page.boxes[0].classes], [])
})

test('a checkbox restyles only its own message', () => {
    const page = pageWith(['first', 'second'])
    assert.equal(page.event(), 'change')

    page.checkboxes[0].checked = false
    page.fire(page.checkboxes[0])
    assert.deepEqual([...page.boxes[0].classes], ['proportional'])
    assert.deepEqual([...page.boxes[1].classes], [])

    page.checkboxes[0].checked = true
    page.fire(page.checkboxes[0])
    assert.deepEqual([...page.boxes[0].classes], [])
})

test('changes to anything else on the page are ignored', () => {
    const page = pageWith(['only'])
    page.fire({classList: {contains: () => false}, closest: () => {
        throw new Error('should not look for a message body')
    }})
    assert.deepEqual([...page.boxes[0].classes], [])
})
