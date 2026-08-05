const {test} = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')

// Read with the comments stripped: these assertions are substring matches, and
// this file explains itself at length, so a rule described in prose would
// otherwise satisfy the test for the rule itself.
const css = fs.readFileSync(path.join(__dirname, '..', 'static', 'archive.css'), 'utf8')
    .replace(/\/\*[\s\S]*?\*\//g, '')
const script = fs.readFileSync(path.join(__dirname, '..', 'static', 'archive.js'), 'utf8')

// Stands in for the DOM of one topic page: message bodies and nothing else a
// reader can touch, which is all the parser writes. Each body records the
// markup the script hands it and the classes the script puts on it.
const pageWith = messageCount => {
    let listener

    const messages = Array.from({length: messageCount}, () => {
        const classes = new Set()
        const strips = []

        return {
            classNames: () => [...classes],
            strips,
            classList: {toggle: (name, on) => (on ? classes.add(name) : classes.delete(name))},
            insertAdjacentHTML: (position, html) => strips.push({position, html}),
        }
    })

    new Function('document', script)({
        addEventListener: (event, handler) => (listener = [event, handler]),
        querySelectorAll: selector => (selector === '.message-text' ? messages : []),
    })

    // A strip as the browser hands it to the listener: the boxes it holds, and
    // the message it sits above. Each box is found by the one selector that
    // walks up from it — the obsolete label on a published page answers to no
    // selector at all, which is the null the listener has to survive.
    const stripAbove = message => {
        const boxes = {}
        const strip = {
            nextElementSibling: message,
            querySelector: selector => boxes[selector.slice(1)] || null,
        }

        ;['monospace', 'line-wrap'].forEach(control => (boxes[control] = {
            checked: true,
            classList: {contains: name => name === control},
            closest: selector => (selector === '.message-controls' ? strip : null),
        }))

        return {box: control => boxes[control]}
    }

    return {messages, stripAbove, change: target => listener[1]({target}), event: () => listener[0]}
}

test('the stylesheet holds the presentation, so pages need no inline styles', () => {
    assert.match(css, /\.message-text\s*\{[^}]*font-family: monospace/)
    assert.match(css, /\.message-text\s*\{[^}]*font-size: 16px/)
    assert.match(css, /\.message-text\s*\{[^}]*line-height: 1\.2/)
    assert.match(css, /\.message-text\s*\{[^}]*white-space: pre-wrap/)
    assert.match(css, /\.message-text\.proportional\s*\{[^}]*font-family: initial/)
    assert.match(css, /\.search-bar\s*\{/)
    assert.match(css, /\.attachment\s*\{/)
    assert.match(css, /\.topic\s*\{/)
    assert.match(css, /\.topic-(date|name|messages|authors)\s*\{/)
})

test('the strip sits at the right of the line, and the published label is gone', () => {
    // Pages published before the controls moved into archive.js still carry a
    // monospace label of their own. Hiding it beats deleting it from the
    // script: it never flashes up in the moment before the script runs, and
    // with JavaScript off a box that could not work is not offered.
    assert.match(css, /\.message-controls\s*\{[^}]*float: right/)
    assert.match(css, /\.message-controls label \+ label\s*\{[^}]*margin-left/)
    assert.match(css, /\.monospace-control\s*\{[^}]*display: none/)

    // The browser greys a disabled box but not the words beside it, which is
    // the half that says what the box is for.
    assert.match(css, /\.message-controls label:has\(input:disabled\)\s*\{[^}]*color:/)
})

test('unchecking line wrap trades wrapping for a scrollbar of the message\'s own', () => {
    // pre keeps the diagram on one line, and the message's own overflow turns
    // that line into a sideways drag rather than a fold. :not(.proportional)
    // is the "no effect when monospace is off" rule: with the diagrams already
    // scrambled by the font there is nothing left for it to save.
    assert.match(css, /\.message-text\.no-wrap:not\(\.proportional\)\s*\{[^}]*white-space: pre;/)

    // The overflow belongs to every state, not just that one. A wrapped
    // message still overflows on anything with no break in it — a long URL,
    // a 200-digit number — and with the scrolling on .no-wrap alone that text
    // was painted outside the box and dragged the page with it: 664px of
    // document on a 320px screen, search bar and every other message in tow.
    assert.match(css, /\.message-text\s*\{[^}]*overflow-x: auto/)

    // A box that scrolls also refuses to sit under a float, and the controls
    // float over its first two pixels: without the clear it makes room for
    // them by shrinking to the width left beside them — 129px of a 319px
    // phone screen. Clearing puts the message back under the whole window.
    assert.match(css, /\.message-text\s*\{[^}]*clear: right/)
})

test('unchecking monospace gives the message back to prose', () => {
    // A proportional font has already lost the diagrams, so the runs of spaces
    // holding them together are noise: normal collapses them the way the
    // archive read before any of this, and line wrap has nothing left to do.
    assert.match(css, /\.message-text\.proportional\s*\{[^}]*white-space: normal/)
})

test('the generated pages carry no styling and no controls of their own', () => {
    // The gate on the whole arrangement: a style attribute or a checkbox
    // written into a page is one more thing a redeploy of the two files cannot
    // change. The search bar is the exception the rule is drawn around — it is
    // a form that submits, so it has to be in the page to work at all.
    const parser = fs.readFileSync(path.join(__dirname, '..', 'parser.js'), 'utf8')
    const messageText = fs.readFileSync(path.join(__dirname, '..', 'messageText.js'), 'utf8')
    const searchBar = fs.readFileSync(path.join(__dirname, '..', 'search', 'searchBar.js'), 'utf8')
    assert.doesNotMatch(parser, /style=/)
    assert.doesNotMatch(searchBar, /style=/)
    assert.doesNotMatch(parser, /<label|<input/)
    assert.doesNotMatch(messageText, /<label|<input/)

    // And the defer is what lets the script find those messages: it builds a
    // strip for each one as the page loads, so run any earlier than this and
    // it sweeps an empty body and no message ever gets a control.
    assert.match(parser, /<script src="\/archive\.js" defer><\/script>/)
})

test('every message is handed a strip of controls the page never carried', () => {
    const page = pageWith(2)

    page.messages.forEach(({strips}) => {
        assert.deepEqual(strips.map(({position}) => position), ['beforebegin'])
        assert.match(strips[0].html, /<div class="message-controls">/)
        assert.match(strips[0].html, /<label><input type="checkbox" class="monospace" checked autocomplete="off"> monospace<\/label>/)
        assert.match(strips[0].html, /<label><input type="checkbox" class="line-wrap" checked autocomplete="off"> line wrap<\/label>/)
    })
})

test('a message starts monospaced and wrapped, before any box is touched', () => {
    // The stylesheet alone decides the initial state, so a message renders
    // right the moment it is parsed: the script only ever answers a click.
    assert.doesNotMatch(script, /font-family|white-space/)
    const page = pageWith(1)
    assert.deepEqual(page.messages[0].classNames(), [])
})

test('unchecking monospace makes only its own message proportional', () => {
    const page = pageWith(2)
    assert.equal(page.event(), 'change')
    const box = page.stripAbove(page.messages[0]).box('monospace')

    box.checked = false
    page.change(box)
    assert.deepEqual(page.messages[0].classNames(), ['proportional'])
    assert.deepEqual(page.messages[1].classNames(), [])

    box.checked = true
    page.change(box)
    assert.deepEqual(page.messages[0].classNames(), [])
})

test('unchecking line wrap stops only its own message from wrapping', () => {
    const page = pageWith(2)
    const strip = page.stripAbove(page.messages[1])
    const box = strip.box('line-wrap')

    box.checked = false
    page.change(box)
    assert.deepEqual(page.messages[1].classNames(), ['no-wrap'])
    assert.deepEqual(page.messages[0].classNames(), [])

    // Neither box knows about the other, so a message can wear both states.
    const monospace = strip.box('monospace')
    monospace.checked = false
    page.change(monospace)
    assert.deepEqual(page.messages[1].classNames(), ['no-wrap', 'proportional'])

    box.checked = true
    page.change(box)
    assert.deepEqual(page.messages[1].classNames(), ['proportional'])
})

test('the line wrap box goes dead while monospace is off, and keeps its setting', () => {
    // Nothing it can do to a proportional message, so it stops offering: a box
    // that answers a click with no visible change reads as broken. It holds on
    // to what the reader chose, though, so monospace coming back brings the
    // message back to the state they left it in rather than to the default.
    const page = pageWith(1)
    const strip = page.stripAbove(page.messages[0])
    const monospace = strip.box('monospace')
    const lineWrap = strip.box('line-wrap')

    lineWrap.checked = false
    page.change(lineWrap)
    assert.ok(!lineWrap.disabled)

    monospace.checked = false
    page.change(monospace)
    assert.equal(lineWrap.disabled, true)
    assert.equal(lineWrap.checked, false)
    assert.deepEqual(page.messages[0].classNames(), ['no-wrap', 'proportional'])

    monospace.checked = true
    page.change(monospace)
    assert.equal(lineWrap.disabled, false)
    assert.deepEqual(page.messages[0].classNames(), ['no-wrap'])
})

test('changes to anything else on the page are ignored', () => {
    // The search bar sits on every page, and its own boxes fire this listener.
    const page = pageWith(1)
    page.change({classList: {contains: () => false}, closest: () => {
        throw new Error('should not look for a message body')
    }})
    assert.deepEqual(page.messages[0].classNames(), [])
})
