/* global createDbWorker, ytgubQuerySql */
(function () {
    const {buildSearchSql, quoteEachTerm, TOPIC_NAME_SQL} = ytgubQuerySql
    const RESULT_STYLE = 'margin: 20px; padding: 10px 20px; background-color: #eee'
    const LIMIT = 20

    const form = document.getElementById('search-form')
    const statusLine = document.getElementById('status')
    const resultsContainer = document.getElementById('results')
    const topicScope = document.getElementById('topic-scope')

    const params = new URLSearchParams(location.search)
    const inputs = {
        q: params.get('q') || '',
        list: params.get('list') || '',
        author: params.get('author') || '',
        after: params.get('after') || '',
        before: params.get('before') || '',
        topic: params.get('topic') || '',
    }

    form.elements.q.value = inputs.q
    form.elements.author.value = inputs.author
    form.elements.after.value = inputs.after
    form.elements.before.value = inputs.before

    fetch(new URL('lists.json', location.href)).then(response => response.json()).then(lists => {
        lists.forEach(name => {
            const option = document.createElement('option')
            option.value = name
            option.textContent = name
            option.selected = name === inputs.list
            form.elements.list.appendChild(option)
        })
    })

    const parseDate = (value, label) => {
        const ms = Date.parse(value)
        if (Number.isNaN(ms)) throw new Error(`invalid ${label} date: ${value}`)
        return ms / 1000
    }

    const setStatus = text => { statusLine.textContent = text }

    const isoDate = postDate => postDate ? new Date(postDate * 1000).toISOString().slice(0, 10) : '????-??-??'

    const appendSnippet = (parent, snippet) => {
        const paragraph = document.createElement('p')
        String(snippet || '').split(/\[([^\]]*)\]/).forEach((piece, index) => {
            if (index % 2) {
                const mark = document.createElement('mark')
                mark.textContent = piece
                paragraph.appendChild(mark)
            } else {
                paragraph.appendChild(document.createTextNode(piece))
            }
        })
        parent.appendChild(paragraph)
    }

    const renderResult = result => {
        const container = document.createElement('div')
        container.style.cssText = RESULT_STYLE

        const meta = document.createElement('div')
        meta.textContent = `${isoDate(result.postDate)} · ${result.list} #${result.msgId} · ${result.author}`
        container.appendChild(meta)

        const heading = document.createElement('h3')
        const link = document.createElement('a')
        link.href = `/${result.list}/message/${result.msgId}.html`
        link.textContent = result.subject
        heading.appendChild(link)
        container.appendChild(heading)

        appendSnippet(container, result.snippet)
        return container
    }

    const showTopicScope = name => {
        if (!inputs.topic) return
        const hidden = document.createElement('input')
        hidden.name = 'topic'
        hidden.type = 'hidden'
        hidden.value = inputs.topic
        form.appendChild(hidden)

        const clearParams = new URLSearchParams(params)
        clearParams.delete('topic')
        topicScope.textContent = `searching within ${name ? `“${name}”` : 'one topic'} — `
        const clear = document.createElement('a')
        clear.href = `?${clearParams.toString()}`
        clear.textContent = 'clear'
        topicScope.appendChild(clear)
    }

    let workerPromise
    const getWorker = () => {
        workerPromise = workerPromise || createDbWorker(
            [{from: 'jsonconfig', configUrl: new URL('db/config.json', location.href).toString()}],
            new URL('lib/sqlite.worker.js', location.href).toString(),
            new URL('lib/sql-wasm.wasm', location.href).toString(),
        )
        return workerPromise
    }

    const run = async () => {
        setStatus('loading search engine…')
        const worker = await getWorker()

        if (inputs.topic && inputs.list) {
            const named = await worker.db.query(TOPIC_NAME_SQL, inputs.list, Number(inputs.topic))
            showTopicScope(named.length ? named[0].subject : null)
        } else if (inputs.topic) {
            showTopicScope(null)
        }

        const {sql, parameters} = buildSearchSql({
            lists: inputs.list ? [inputs.list] : undefined,
            topicId: inputs.topic ? Number(inputs.topic) : undefined,
            author: inputs.author || undefined,
            after: inputs.after ? parseDate(inputs.after, 'after') : undefined,
            before: inputs.before ? parseDate(inputs.before, 'before') : undefined,
        })

        setStatus('searching…')
        let rows
        try {
            rows = await worker.db.query(sql, inputs.q, ...parameters, LIMIT)
        } catch (error) {
            const sanitized = quoteEachTerm(inputs.q)
            if (!sanitized) {
                setStatus('')
                return
            }
            rows = await worker.db.query(sql, sanitized, ...parameters, LIMIT)
        }

        if (!rows.length) {
            setStatus('No matches.')
            return
        }
        setStatus(`${rows.length} result${rows.length > 1 ? 's' : ''}${rows.length === LIMIT ? ' (showing first ' + LIMIT + ')' : ''}`)
        rows.forEach(row => resultsContainer.appendChild(renderResult(row)))
    }

    if (inputs.q.trim()) {
        run().catch(error => setStatus(String(error && error.message || error)))
    } else if (inputs.topic) {
        showTopicScope(null)
    }
})()
