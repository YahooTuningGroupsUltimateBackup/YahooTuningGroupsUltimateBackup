// Markup for a message: a box with a class and nothing else. How it looks
// lives in static/archive.css and the controls over it live in
// static/archive.js, so restyling the archive never means regenerating pages.
const messageTextHtml = text => `<div class="message-text">${text}</div>`

module.exports = {messageTextHtml}
