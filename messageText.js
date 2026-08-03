const MONOSPACE_CONTROL_STYLE = 'float: right; margin-right: 20px'

// Marks the message body divs the checkbox restyles. The whole body is styled
// rather than its paragraphs, because mills list messages are plain text joined
// with <br> and contain no <p> to hook onto.
const MESSAGE_TEXT_CLASS = 'message-text'

// The size and line-height are pinned so a message occupies the same height in
// either font: left to the browser, a generic monospace family comes out a few
// pixels smaller than the default font, and line-height: normal is derived from
// whichever font is in play. With both fixed, only the line count moves the box.
// The leading is kept tight because 16px monospace advances 9.6px per character,
// so 1.2 puts a character cell at about 2:1 — the proportion the ASCII lattice
// diagrams all over these lists were drawn at. Anything looser stretches them.
// pre-wrap because HTML otherwise collapses the runs of spaces that hold an
// ASCII lattice together. Nothing here writes newlines into the markup, so line
// breaks keep coming from the <br> tags rather than doubling up.
const MESSAGE_TEXT_STYLE = 'margin: 0px 20px 20px; padding: 20px; background-color: #eee; font-size: 16px; line-height: 1.2; white-space: pre-wrap'

const messageTextHtml = text => `<div class='${MESSAGE_TEXT_CLASS}' style='${MESSAGE_TEXT_STYLE}'>${text}</div>`

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

module.exports = {MESSAGE_TEXT_CLASS, messageTextHtml, monospaceControlHtml, monospaceScriptHtml}
