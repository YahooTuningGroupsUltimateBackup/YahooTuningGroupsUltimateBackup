// The controls a reader gets over a message, and what they do. A page is raw
// material — an author, a date, a message — so the checkboxes are built here
// rather than baked into 36,000-odd pages: adding one is a redeploy of this
// file and archive.css, with the pages left alone.

// Each box says where it starts and names the class its message wears while it
// sits anywhere else; archive.css decides what that class means, and its bare
// .message-text rules are the state every box in its starting position adds up
// to — so a message renders right before this file has run at all. A box that
// needs another is only live while that one is checked: line wrap has no
// purchase on a message the font has already unscrambled.
const CONTROLS = [
    {name: 'monospace', text: 'monospace', checked: true, otherwise: 'proportional'},
    {name: 'line-wrap', text: 'line wrap', checked: false, otherwise: 'wrap', needs: 'monospace'},
]

// autocomplete="off" is what keeps a box from lying. Coming back to a page,
// the browser restores the boxes it remembers to what they were, but the
// classes they set are not part of that memory: the box would show the
// reader's old choice over a message the stylesheet had put back to the
// default, and the first click on it would appear to do nothing, having only
// put the box back where it already looked.
const CONTROLS_HTML = `<div class="message-controls">${CONTROLS.map(({name, text, checked}) =>
    `<label><input type="checkbox" class="${name}"${checked ? ' checked' : ''} autocomplete="off"> ${text}</label>`).join('')}</div>`

document.querySelectorAll('.message-text').forEach(message =>
    message.insertAdjacentHTML('beforebegin', CONTROLS_HTML))

// One delegated listener for the whole page: a box restyles the message its
// strip sits above, and nothing else.
document.addEventListener('change', event => {
    const checkbox = event.target
    const control = CONTROLS.find(({name}) => checkbox.classList.contains(name))
    if (!control) return

    const strip = checkbox.closest('.message-controls')
    strip.nextElementSibling.classList.toggle(control.otherwise, checkbox.checked !== control.checked)

    // A box with nothing to do is greyed out rather than left looking live —
    // one that answers a click with no visible change reads as broken. It
    // keeps its own setting while it waits, so the box it depends on coming
    // back brings the message back to what the reader last chose.
    CONTROLS.filter(({needs}) => needs).forEach(({name, needs}) =>
        (strip.querySelector(`.${name}`).disabled = !strip.querySelector(`.${needs}`).checked))
})
