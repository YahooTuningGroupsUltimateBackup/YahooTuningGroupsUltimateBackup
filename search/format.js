const ONLINE_ROOT = 'https://yahootuninggroupsultimatebackup.github.io'

const messageUrl = (list, msgId) => `${ONLINE_ROOT}/${list}/message/${msgId}.html`

const isoDate = postDate =>
    postDate ? new Date(postDate * 1000).toISOString().slice(0, 10) : '????-??-??'

const formatResult = ({list, msgId, postDate, author, subject, snippet}) => [
    `${isoDate(postDate)}  ${list} #${msgId}  ${author}`,
    `  ${subject}`,
    `  ${snippet}`,
    `  ${messageUrl(list, msgId)}`,
].join('\n')

module.exports = {formatResult, messageUrl, isoDate}
