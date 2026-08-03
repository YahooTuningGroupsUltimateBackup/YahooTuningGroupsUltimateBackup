// One delegated listener for the whole topic page: each checkbox restyles the
// message body that follows it, and nothing else. The stylesheet decides how a
// message starts out, so this file only ever handles a reader's click.
document.addEventListener('change', event => {
    const checkbox = event.target
    if (!checkbox.classList || !checkbox.classList.contains('monospace')) return

    const messageText = checkbox.closest('.monospace-control').nextElementSibling
    messageText.classList.toggle('proportional', !checkbox.checked)
})
