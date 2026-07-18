The archive is browsable and searchable online at https://yahootuninggroupsultimatebackup.github.io/ — every page carries a search bar scoped to where you are, and https://yahootuninggroupsultimatebackup.github.io/search/ is the full search form. Clone this repo to search locally instead (faster queries, no download per search).

# searching locally

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

Or search in the browser: `make start` and open http://localhost:3000. Every page of the locally served site (run `make parse` once to generate it) carries the same scoped search bar as the online version, served by a local /search route against your local index.

# deploying the site

The online search runs entirely in the browser: SQLite compiled to WebAssembly (vendored sql.js-httpvfs) fetches only the needed pages of the index over HTTP range requests, so GitHub Pages can host it with no server. A query downloads a few MB on first use. To rebuild and redeploy everything:

```
make parse                  # regenerate dist/ (pages include the search bars)
npm run index               # rebuild search-index.db from src/
node search.js deploy-site  # assemble dist/search/: page, engine, chunked db, .nojekyll
npm run transfer            # copy dist/ into ../YahooTuningGroupsUltimateBackup.github.io
```

then commit and push the github.io repo. The database is split into 10MB chunks to stay under GitHub's per-file limit.
