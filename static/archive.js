// The controls a reader gets over a message, and what they do. A page is raw
// material — an author, a date, a message — so the checkboxes are built here
// rather than baked into 36,000-odd pages: adding one is a redeploy of this
// file and archive.css, with the pages left alone.

// Each box names the class its message wears while the box is unchecked;
// archive.css decides what that class means.
const CONTROLS = [
    {name: 'monospace', text: 'monospace', unchecked: 'proportional'},
    {name: 'line-wrap', text: 'line wrap', unchecked: 'no-wrap'},
]

// autocomplete="off" is what keeps a box from lying. Coming back to a page,
// the browser restores the boxes it remembers to what they were, but the
// classes they set are not part of that memory: the box would read unchecked
// over a message that had gone back to wrapping, and the first click on it
// would appear to do nothing, having only put the box back where it looked.
const CONTROLS_HTML = `<div class="message-controls">${CONTROLS.map(({name, text}) =>
    `<label><input type="checkbox" class="${name}" checked autocomplete="off"> ${text}</label>`).join('')}</div>`

document.querySelectorAll('.message-text').forEach(message =>
    message.insertAdjacentHTML('beforebegin', CONTROLS_HTML))

// One delegated listener for the whole page: a box restyles the message its
// strip sits above, and nothing else.
document.addEventListener('change', event => {
    const checkbox = event.target
    const control = CONTROLS.find(({name}) => checkbox.classList.contains(name))
    if (!control) return

    const message = checkbox.closest('.message-controls').nextElementSibling
    message.classList.toggle(control.unchecked, !checkbox.checked)
})
