# Project Agent Instructions

## Hand over a demo before calling a reader-facing change done

Anything that changes what a reader sees — `static/archive.css`,
`static/archive.js`, or the markup a page carries — is not delivered until the
user has a page in front of him to accept or reject. Passing tests and your own
browser check prove the code does what you wrote; they cannot tell him whether
the archive reads better for it, which is the only question he is answering.
Skip the demo and he has to ask for one after being told the work was finished,
which is where this rule came from.

`dist/buildDemo.js` builds one: real messages out of `src/` run through the same
`messageTextHtml` and `searchBarHtml` that write a real topic page, with
`static/archive.css` and `static/archive.js` copied beside it and linked
relatively so the page opens on a double-click with no server behind it. Extend
that script rather than starting over, and pick messages that exercise the
change — an ASCII lattice for anything touching wrapping, fonts, or spacing;
one of the Yahoo lists and the Mills list together, since Yahoo posts arrive
hard-wrapped at about 72 columns and Mills prose was never wrapped at all.
`dist/` is gitignored, so a demo never dirties the tree. Hand over a `file:///`
link to the HTML file itself.

The near miss that still counts: a hand-written mock page with invented
messages. It exercises the same stylesheet and the same script, and it still
fails — he is judging how the archive reads, and text you made up cannot show
him that.

## Deploying is his call

Copying the assets into `../YahooTuningGroupsUltimateBackup.github.io/`, and any
commit in that repo, publishes to a live public site. Wait for the word to ship,
every time, however small the change.
