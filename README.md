The web version at https://yahootuninggroupsultimatebackup.github.io/ is not easily searchable. Clone this repo down and search locally, then use the message ID to access the pages online for a fuller browsing experience.

# searching

Requires Node.js 22.5+ (the index uses Node's built-in SQLite with full-text search). On a fresh clone run `make setup` first, then build the index (one-time, under a minute; the ~500MB `search-index.db` file it creates is gitignored):

```
npm run index
```

Then search from the command line:

```
node search.js "porcupine temperament"
node search.js miracle --list tuning-math --author erlich --after 2001 --before 2002-06
node search.js "blackjack NEAR scale" --limit 50
```

Bare words are ANDed; `"quoted phrases"`, `OR`, `NOT`, and `NEAR(a b, n)` are SQLite FTS5 syntax. Every match prints a snippet plus the message's URL on the online backup.

Or search in the browser: `make start` and open http://localhost:3000. Every page of the locally served site (run `make parse` once to generate it) carries a search bar scoped to the list — or, on a topic page, the topic — you are looking at, and http://localhost:3000/search is the full search form with all filters. Result titles link into the local site; the "view online" links work regardless.
