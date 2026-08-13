# Project Agent Instructions

## The demo mechanism

`node dist/buildDemo.js` builds what the acceptance step needs here: real
messages out of `src/` run through the same `messageTextHtml` and
`searchBarHtml` that write a real topic page, with `static/archive.css` and
`static/archive.js` copied beside it and linked relatively, so the page opens on
a double-click with no server behind it. Extend it for the change at hand — pick
messages that exercise it, and keep one Yahoo-list topic alongside a Mills one,
since Yahoo posts arrive hard-wrapped at about 72 columns while Mills prose was
never wrapped at all. `dist/` is gitignored. Hand over a `file:///` link to the
HTML file itself.

## The publish step

`cp static/archive.css static/archive.js ../YahooTuningGroupsUltimateBackup.github.io/`
plus a commit in that repo puts the change on a live public site, so that repo is
where shipping actually happens — merging to this one's `main` does not.
