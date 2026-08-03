// Markup for a message and its font control. Both are class-only: how they look
// lives in static/archive.css, and how the control behaves lives in
// static/archive.js, so restyling the archive never means regenerating pages.
const MESSAGE_TEXT_CLASS = 'message-text'

const messageTextHtml = text => `<div class="${MESSAGE_TEXT_CLASS}">${text}</div>`

const monospaceControlHtml = () => `<label class="monospace-control"><input type="checkbox" class="monospace" checked> monospace</label>`

module.exports = {MESSAGE_TEXT_CLASS, messageTextHtml, monospaceControlHtml}
