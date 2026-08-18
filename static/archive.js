// The controls a reader gets over a message, and what they do. A page is raw
// material — an author, a date, a message — so the checkboxes are built here
// rather than baked into 36,000-odd pages: adding one is a redeploy of this
// file and archive.css, with the pages left alone.

// Yahoo's mail clients hard-wrapped outgoing posts at about 72 columns, so a
// line past this width is one no client ever folded: the message carries a
// whole paragraph per line, and unfolded that is a sideways drag from its
// first line to its last rather than the odd wide diagram. The width sits just
// above the hard wrap rather than at it, so a post that wrapped at 72 or 74 is
// not read as one that was never wrapped at all.
const HARD_WRAP_COLUMNS = 75

// Each box says where it starts and names the class its message wears while it
// sits anywhere else; archive.css decides what that class means, and its bare
// .message-text rules are the state every box in the position `checked` names
// adds up to — so a message renders right before this file has run at all. A
// box starts the other way for a message that argues for it, which `unless` is
// the argument of, and that message is given the class in the same breath, so
// box and message never disagree. A box that needs another is only live while
// that one is checked: line wrap has no purchase on a message the font has
// already unscrambled.
const CONTROLS = [
    {name: 'monospace', text: 'monospace', checked: true, otherwise: 'proportional'},
    {name: 'line-wrap', text: 'line wrap', checked: false, otherwise: 'wrap', needs: 'monospace',
        unless: text => text.split('\n').some(line => line.length > HARD_WRAP_COLUMNS)},
]

// autocomplete="off" is what keeps a box from lying. Coming back to a page,
// the browser restores the boxes it remembers to what they were, but the
// classes they set are not part of that memory: the box would show the
// reader's old choice over a message the stylesheet had put back to the
// default, and the first click on it would appear to do nothing, having only
// put the box back where it already looked.
const boxesHtml = positions => CONTROLS.map(({name, text}, box) =>
    `<label><input type="checkbox" class="${name}"${positions[box] ? ' checked' : ''} autocomplete="off"> ${text}</label>`).join('')

const stripHtml = positions => `<div class="message-controls">${boxesHtml(positions)}</div>`

// The same pair once more under the search bar, named out to the left of them
// and wearing the strip's own class, which is what stands them in the column
// every pair below them stands in. They are a switch over all of those rather
// than a setting of their own: a click pushes a value down into every message
// box, and any change at all is read back up off them afterwards.
const formatAllHtml = positions =>
    `<div class="message-controls format-all"><span>format all:</span>${boxesHtml(positions)}</div>`

// The one rule tying a box to the message under it, shared by the strip going
// up and every click after it: anywhere but the position the stylesheet draws,
// the message wears the class the box names.
const restyle = (message, {otherwise, checked}, position) =>
    message.classList.toggle(otherwise, position !== checked)

// Every message is read before any strip goes up, rather than one message at a
// time: innerText is answered out of the page's layout, and a strip inserted
// between two reads makes the browser lay the whole page out again to answer
// the second.
const messages = [...document.querySelectorAll('.message-text')]
const positions = messages.map(message =>
    CONTROLS.map(({checked, unless}) => (unless?.(message.innerText) ? !checked : checked)))

messages.forEach((message, index) => {
    message.insertAdjacentHTML('beforebegin', stripHtml(positions[index]))
    CONTROLS.forEach((control, box) => restyle(message, control, positions[index][box]))
})

const boxIn = (strip, name) => strip.querySelector(`.${name}`)
const messageStrips = () => [...document.querySelectorAll('.message-controls:not(.format-all)')]

// A box with nothing to do is greyed out rather than left looking live — one
// that answers a click with no visible change reads as broken. It keeps its own
// setting while it waits, so the box it depends on coming back brings the
// message back to what the reader last chose. On the switch, neutral counts as
// live: a mix below it still holds monospaced messages for a fold to fold, and
// only every message losing the font leaves it nothing to do.
const greyDead = strip => CONTROLS.filter(({needs}) => needs).forEach(({name, needs}) => {
    const needed = boxIn(strip, needs)
    boxIn(strip, name).disabled = !needed.checked && !needed.indeterminate
})

// The switch is a click on every box below it at once, and a mix down there is
// neither on nor off: the first click on a neutral box turns everything on, and
// only a box already fully checked has anything to turn off. The browser has
// flipped the switch's own box before this runs, and which way it flipped an
// indeterminate one is not something to build on, so what happens is decided by
// the boxes below. Each of them then does with its new position exactly what a
// click on it would have done.
const formatAll = control => {
    const strips = messageStrips()
    const checked = !strips.every(strip => boxIn(strip, control.name).checked)

    strips.forEach(strip => {
        boxIn(strip, control.name).checked = checked
        restyle(strip.nextElementSibling, control, checked)
        greyDead(strip)
    })
}

// And what the switch shows is only ever what it finds below it: every box
// checked, every box unchecked, or the mix in between, which is a box that is
// neither.
const readBack = strip => {
    const strips = messageStrips()

    CONTROLS.forEach(({name}) => {
        const below = strips.map(messageStrip => boxIn(messageStrip, name))
        const box = boxIn(strip, name)
        box.checked = below.every(({checked}) => checked)
        box.indeterminate = !box.checked && below.some(({checked}) => checked)
    })

    greyDead(strip)
}

// An index page has no messages to work and so is offered no switch. The
// search bar is where it goes on the pages that do: the one thing on a topic
// page that already sits above every message.
const searchBar = messages.length && document.querySelector('.search-bar')
if (searchBar) {
    // It goes up in the position the messages agree on, and is told what they
    // actually add up to in the same breath — a message that arrived folded is
    // why they may not agree.
    const agreed = [...CONTROLS.keys()].map(box => positions.every(position => position[box]))

    searchBar.insertAdjacentHTML('afterend', formatAllHtml(agreed))
    readBack(document.querySelector('.format-all'))
}

// One delegated listener for the whole page: a box in a message's own strip
// restyles that message and nothing else, a box in the switch works every one
// of them, and either way the switch ends up saying what the page now is.
document.addEventListener('change', event => {
    const checkbox = event.target
    const control = CONTROLS.find(({name}) => checkbox.classList.contains(name))
    if (!control) return

    const strip = checkbox.closest('.message-controls')
    const all = document.querySelector('.format-all')

    if (strip === all) {
        formatAll(control)
    } else {
        restyle(strip.nextElementSibling, control, checkbox.checked)
        greyDead(strip)
    }

    if (all) readBack(all)
})
