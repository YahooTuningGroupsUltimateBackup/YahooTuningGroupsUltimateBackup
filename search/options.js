const parseDate = value => {
    const ms = Date.parse(value)
    if (Number.isNaN(ms)) throw new Error(`invalid date: ${value}`)
    return ms / 1000
}

const parseLimit = value => {
    const limit = Number(value)
    if (!Number.isInteger(limit) || limit < 1) throw new Error(`invalid limit: ${value}`)
    return limit
}

const searchOptions = ({lists, author, after, before, limit}) => ({
    lists: lists && lists.flatMap(value => value.split(',')).filter(Boolean),
    author: author || undefined,
    after: after ? parseDate(after) : undefined,
    before: before ? parseDate(before) : undefined,
    limit: limit ? parseLimit(limit) : undefined,
})

module.exports = {searchOptions}
