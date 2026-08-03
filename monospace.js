const MONOSPACE_CONTROL_STYLE = 'float: right; margin-right: 20px'

// Marks the message body divs the checkbox restyles. The whole body is styled
// rather than its paragraphs, because mills list messages are plain text joined
// with <br> and contain no <p> to hook onto.
const MESSAGE_TEXT_CLASS = 'message-text'

// Every message carries its own checkbox, but the setting is page-wide: flipping
// one restyles the whole topic and syncs the rest. Pages start monospaced, since
// these are plain-text mailing list posts whose tables and diagrams need it.
const monospaceControlHtml = () => `<label style="${MONOSPACE_CONTROL_STYLE}"><input type="checkbox" class="monospace" checked> monospace</label>`

const monospaceScriptHtml = () => `
    <script>
        const applyMonospace = monospace => {
            $('.monospace').prop('checked', monospace)
            $('.${MESSAGE_TEXT_CLASS}').css('font-family', monospace ? 'monospace' : '')
        }

        applyMonospace(true)

        $('.monospace').on('change', function () {
            applyMonospace(this.checked)
        })
    </script>
`

module.exports = {MESSAGE_TEXT_CLASS, monospaceControlHtml, monospaceScriptHtml}
