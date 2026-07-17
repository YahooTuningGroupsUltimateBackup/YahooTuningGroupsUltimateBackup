const parseDate = value => {
    const ms = Date.parse(value)
    if (Number.isNaN(ms)) throw new Error(`invalid date: ${value}`)
    return ms / 1000
}

const parsePositiveInteger = (value, label) => {
    const parsed = Number(value)
    if (!Number.isInteger(parsed) || parsed < 1) throw new Error(`invalid ${label}: ${value}`)
    return parsed
}

const searchOptions = ({lists, author, after, before, limit, topicId}) => ({
    lists: lists && lists.flatMap(value => value.split(',')).filter(Boolean),
    author: author || undefined,
    after: after ? parseDate(after) : undefined,
    before: before ? parseDate(before) : undefined,
    limit: limit ? parsePositiveInteger(limit, 'limit') : undefined,
    topicId: topicId ? parsePositiveInteger(topicId, 'topic') : undefined,
})

module.exports = {searchOptions}
