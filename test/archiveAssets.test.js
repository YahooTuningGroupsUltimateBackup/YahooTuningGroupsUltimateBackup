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

// Stands in for the DOM of one topic page: a search bar, message bodies, and
// nothing else a reader can touch, which is all the parser writes. Each body is
// handed the text a reader sees — innerText, whose lines are the ones the
// browser lays out rather than the <br>-separated markup behind them — and
// records the markup the script gives it and the classes the script puts on it;
// the bar records the switch the script hangs under it.
const pageWith = (...texts) => {
    let listener

    const messages = texts.map(innerText => {
        const classes = new Set()
        const strips = []

        return {
            innerText,
            classNames: () => [...classes],
            strips,
            classList: {toggle: (name, on) => (on ? classes.add(name) : classes.delete(name))},
            insertAdjacentHTML: (position, html) => strips.push({position, html}),
        }
    })

    // A strip as the browser hands it to the listener: the boxes it holds, in
    // the positions the script wrote them, and the message it sits above — none,
    // for the switch under the search bar, which styles nothing itself. Each box
    // is found by the one selector that walks up from it — the obsolete label on
    // a published page answers to no selector at all, which is the null the
    // listener has to survive.
    const stripFrom = (html, message) => {
        const boxes = {}
        const strip = {
            nextElementSibling: message,
            querySelector: selector => boxes[selector.slice(1)] || null,
            box: control => boxes[control],
        }

        for (const [, control, attributes] of html.matchAll(/<input type="checkbox" class="([\w-]+)"([^>]*)>/g))
            boxes[control] = {
                checked: attributes.includes(' checked'),
                classList: {contains: name => name === control},
                closest: selector => (selector === '.message-controls' ? strip : null),
            }

        return strip
    }

    // Each strip is built the once, the first time anything asks for it: the
    // script goes looking for every strip on the page, and one minted fresh per
    // lookup would forget what the last click did to it.
    let built
    let switched
    const inserts = []
    const searchBar = {inserts, insertAdjacentHTML: (position, html) => inserts.push({position, html})}
    const strips = () => (built ??= messages.map(message => stripFrom(message.strips[0].html, message)))
    // The switch is on the page only once the script has hung it there, so a
    // page it passed over answers for it with the null it answered with before
    // the script ran.
    const formatAll = () => (inserts.length ? (switched ??= stripFrom(inserts[0].html, null)) : null)

    new Function('document', script)({
        addEventListener: (event, handler) => (listener = [event, handler]),
        querySelectorAll: selector => selector === '.message-text' ? messages
            : selector === '.message-controls:not(.format-all)' ? strips()
            : [],
        querySelector: selector => selector === '.search-bar' ? searchBar
            : selector === '.format-all' ? formatAll()
            : null,
    })

    return {
        messages,
        searchBar,
        formatAll: formatAll(),
        stripAbove: message => strips()[messages.indexOf(message)],
        change: target => listener[1]({target}),
        event: () => listener[0],
    }
}

test('the stylesheet holds the presentation, so pages need no inline styles', () => {
    assert.match(css, /\.message-text\s*\{[^}]*font-family: monospace/)
    assert.match(css, /\.message-text\s*\{[^}]*font-size: 16px/)
    assert.match(css, /\.message-text\s*\{[^}]*line-height: 1\.2/)
    assert.match(css, /\.message-text\s*\{[^}]*white-space: pre;/)
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

test('the switch stands its boxes in the column the message strips stand in', () => {
    // It hangs under the search bar rather than riding a message's date line,
    // so it takes a line of its own instead of floating onto one — and
    // right-aligning it to the margin those strips float to is what puts its
    // two boxes directly over every pair below them.
    assert.match(css, /\.format-all\s*\{[^}]*float: none/)
    assert.match(css, /\.format-all\s*\{[^}]*text-align: right/)
})

test('checking line wrap trades the message\'s own scrollbar for wrapping', () => {
    // Left alone, pre keeps the diagram on the line it was drawn on and the
    // message's own overflow turns that line into a sideways drag rather than
    // a fold; the box gives a reader who would rather have prose the fold
    // back. :not(.proportional) is the "no effect when monospace is off" rule:
    // with the diagrams already scrambled by the font there is nothing left
    // for it to save.
    assert.match(css, /\.message-text\.wrap:not\(\.proportional\)\s*\{[^}]*white-space: pre-wrap;/)

    // The overflow belongs to every state, not just the unwrapped one. A
    // wrapped message still overflows on anything with no break in it — a long
    // URL, a 200-digit number — and with the scrolling left off that text is
    // painted outside the box and drags the page with it: 664px of document on
    // a 320px screen, search bar and every other message in tow.
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
    const page = pageWith('a message', 'another message')

    page.messages.forEach(({strips}) => {
        assert.deepEqual(strips.map(({position}) => position), ['beforebegin'])
        assert.match(strips[0].html, /<div class="message-controls">/)
        assert.match(strips[0].html, /<label><input type="checkbox" class="monospace" checked autocomplete="off"> monospace<\/label>/)
        assert.match(strips[0].html, /<label><input type="checkbox" class="line-wrap" autocomplete="off"> line wrap<\/label>/)
    })
})

test('a message starts monospaced and unwrapped, before any box is touched', () => {
    // The stylesheet alone decides the initial state, so a message renders
    // right the moment it is parsed: the script only ever answers a click.
    assert.doesNotMatch(script, /font-family|white-space/)
    const page = pageWith('a message')
    assert.deepEqual(page.messages[0].classNames(), [])
})

test('a message no client ever wrapped arrives folded, its box checked to say so', () => {
    // Yahoo's mail clients hard-wrapped outgoing posts at about 72 columns, so
    // a line past that width is one nobody folded: the message carries a
    // paragraph per line, and unfolded that is a sideways drag from its first
    // line to its last rather than the odd wide diagram. It starts folded
    // instead — and the box starts checked, since a box that disagrees with
    // the message under it answers its first click by appearing to do nothing.
    const page = pageWith('x'.repeat(76), `${'x'.repeat(75)}
${'x'.repeat(70)}`)

    assert.match(page.messages[0].strips[0].html, /class="line-wrap" checked/)
    assert.deepEqual(page.messages[0].classNames(), ['wrap'])

    assert.match(page.messages[1].strips[0].html, /class="line-wrap" autocomplete/)
    assert.deepEqual(page.messages[1].classNames(), [])
})

test('unchecking monospace makes only its own message proportional', () => {
    const page = pageWith('a message', 'another message')
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

test('checking line wrap folds only its own message', () => {
    const page = pageWith('a message', 'another message')
    const strip = page.stripAbove(page.messages[1])
    const box = strip.box('line-wrap')

    box.checked = true
    page.change(box)
    assert.deepEqual(page.messages[1].classNames(), ['wrap'])
    assert.deepEqual(page.messages[0].classNames(), [])

    // Neither box knows about the other, so a message can wear both states.
    const monospace = strip.box('monospace')
    monospace.checked = false
    page.change(monospace)
    assert.deepEqual(page.messages[1].classNames(), ['wrap', 'proportional'])

    box.checked = false
    page.change(box)
    assert.deepEqual(page.messages[1].classNames(), ['proportional'])
})

test('a message that arrived folded is unfolded by the box, not folded again', () => {
    // The box over such a message starts checked, so the reader's first click
    // takes the fold away. Nothing about the message is remembered past that:
    // checking it again folds it back, the same as for any other message.
    const page = pageWith('x'.repeat(76))
    const box = page.stripAbove(page.messages[0]).box('line-wrap')

    box.checked = false
    page.change(box)
    assert.deepEqual(page.messages[0].classNames(), [])

    box.checked = true
    page.change(box)
    assert.deepEqual(page.messages[0].classNames(), ['wrap'])
})

test('the line wrap box goes dead while monospace is off, and keeps its setting', () => {
    // Nothing it can do to a proportional message, so it stops offering: a box
    // that answers a click with no visible change reads as broken. It holds on
    // to what the reader chose, though, so monospace coming back brings the
    // message back to the state they left it in rather than to the default.
    const page = pageWith('a message')
    const strip = page.stripAbove(page.messages[0])
    const monospace = strip.box('monospace')
    const lineWrap = strip.box('line-wrap')

    lineWrap.checked = true
    page.change(lineWrap)
    assert.ok(!lineWrap.disabled)

    monospace.checked = false
    page.change(monospace)
    assert.equal(lineWrap.disabled, true)
    assert.equal(lineWrap.checked, true)
    assert.deepEqual(page.messages[0].classNames(), ['wrap', 'proportional'])

    monospace.checked = true
    page.change(monospace)
    assert.equal(lineWrap.disabled, false)
    assert.deepEqual(page.messages[0].classNames(), ['wrap'])
})

test('the page gets one switch over all of its messages, under the search bar', () => {
    const page = pageWith('a message', 'another message')
    const [{position, html}] = page.searchBar.inserts

    assert.equal(page.searchBar.inserts.length, 1)
    assert.equal(position, 'afterend')
    assert.match(html, /<div class="message-controls format-all"><span>format all:<\/span>/)
    assert.match(html, /<label><input type="checkbox" class="monospace" checked autocomplete="off"> monospace<\/label>/)
    assert.match(html, /<label><input type="checkbox" class="line-wrap" autocomplete="off"> line wrap<\/label>/)
})

test('a page with no messages to work is offered no switch', () => {
    // Every list index page carries the same search bar, and nothing under it.
    assert.deepEqual(pageWith().searchBar.inserts, [])
})

test('the switch opens neutral over messages that arrived formatted differently', () => {
    // One of these was folded on arrival and the other was not, so the switch
    // is neither of those things from the moment the page opens — before any
    // reader has touched a box.
    const page = pageWith('x'.repeat(76), 'a message')

    assert.match(page.searchBar.inserts[0].html, /class="line-wrap" autocomplete/)
    assert.equal(page.formatAll.box('line-wrap').checked, false)
    assert.equal(page.formatAll.box('line-wrap').indeterminate, true)
    assert.equal(page.formatAll.box('monospace').checked, true)
    assert.equal(page.formatAll.box('monospace').indeterminate, false)
})

test('the switch checks every box below it before it can uncheck any', () => {
    // A mix below is neither on nor off, so the first click on it turns
    // everything on rather than reading as the off it half looks like. The
    // browser has flipped the switch's own box before the listener sees it, and
    // which way it flipped an indeterminate box is not something to build on:
    // what the switch does is decided by the boxes below it, which is why the
    // clicks here leave its own box alone.
    const page = pageWith('a message', 'another message', 'a third message')
    const all = page.formatAll.box('line-wrap')
    const one = page.stripAbove(page.messages[1]).box('line-wrap')

    one.checked = true
    page.change(one)
    assert.equal(all.checked, false)
    assert.equal(all.indeterminate, true)

    page.change(all)
    page.messages.forEach(message => assert.deepEqual(message.classNames(), ['wrap']))
    assert.equal(all.checked, true)
    assert.equal(all.indeterminate, false)

    // Fully checked is the one state that has anything to turn off.
    page.change(all)
    page.messages.forEach(message => assert.deepEqual(message.classNames(), []))
    assert.equal(all.checked, false)
    assert.equal(all.indeterminate, false)

    // And fully unchecked turns everything back on, the same as the mix did.
    page.change(all)
    page.messages.forEach(message => assert.deepEqual(message.classNames(), ['wrap']))
    assert.equal(all.checked, true)
})

test('the switch says what the messages say, whichever of them was touched', () => {
    const page = pageWith('a message', 'another message')
    const all = page.formatAll.box('monospace')
    const first = page.stripAbove(page.messages[0]).box('monospace')
    const second = page.stripAbove(page.messages[1]).box('monospace')

    first.checked = false
    page.change(first)
    assert.equal(all.checked, false)
    assert.equal(all.indeterminate, true)

    second.checked = false
    page.change(second)
    assert.equal(all.checked, false)
    assert.equal(all.indeterminate, false)

    first.checked = true
    second.checked = true
    page.change(first)
    assert.equal(all.checked, true)
    assert.equal(all.indeterminate, false)
})

test('the switch\'s line wrap goes dead only once no message is monospaced', () => {
    // Neutral leaves it live: some of the messages under it are still in the
    // font that gives a fold something to fold.
    const page = pageWith('a message', 'another message')
    const monospace = page.formatAll.box('monospace')
    const lineWrap = page.formatAll.box('line-wrap')
    const first = page.stripAbove(page.messages[0]).box('monospace')

    first.checked = false
    page.change(first)
    assert.equal(monospace.indeterminate, true)
    assert.ok(!lineWrap.disabled)

    page.change(monospace)
    assert.equal(monospace.checked, true)
    assert.ok(!lineWrap.disabled)
    page.messages.forEach(message => assert.deepEqual(message.classNames(), []))

    page.change(monospace)
    assert.equal(lineWrap.disabled, true)
    page.messages.forEach(message => assert.deepEqual(message.classNames(), ['proportional']))
    page.messages.forEach(message =>
        assert.equal(page.stripAbove(message).box('line-wrap').disabled, true))
})

test('changes to anything else on the page are ignored', () => {
    // The search bar sits on every page, and its own boxes fire this listener.
    const page = pageWith('a message')
    page.change({classList: {contains: () => false}, closest: () => {
        throw new Error('should not look for a message body')
    }})
    assert.deepEqual(page.messages[0].classNames(), [])
})
