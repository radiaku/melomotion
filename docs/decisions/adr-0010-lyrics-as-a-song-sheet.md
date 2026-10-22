---
title: "ADR 0010: Lay lyrics out as a song sheet"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0010: Lay lyrics out as a song sheet

Accepted 2026-10-22. Supersedes [[adr-0009-show-recordings-as-lyrics]].

## Context

The first `:Melomotion show` ([[adr-0009-show-recordings-as-lyrics]]) worked but read like a log: a rule for a header, a `♪` per file, keys under it. The maintainer found it "not artistic". Two directions were mocked up from a real session. Sheet music put notes above each key, as high as the cursor sat on screen, with the keys underneath. A song sheet laid the session out like printed lyrics. The maintainer chose the song sheet.

## Decision

- The session is a song. Its title is the place you moved in most, "feat." the runner-up. Under it go the date, the start time and the length as `m:ss`.
- Each stay in a place is a part of the song, labelled `[Part: place]`. Back-to-back repeats are one **Chorus ×n**. A stay where you moved is a **Verse**, or a **Chorus** if it's heard again later. A run of places you only passed through is a **Bridge**. The first and last parts become the **Intro** and **Outro**, unless they're a chorus.
- A lyric line is the keys that took you there, `~`, then the keys you moved with, framed by `♪`. The song's last line ends on `♫`.
- Pauses phrase the lyrics: a comma after 1 s, a new line after 3 s.
- Runs of up to three keys are sung out (`j j j`), and longer ones fold (`j×7`).
- Places are named by file name. Paths are shown only to tell apart files that share one.
- These parts of ADR 0009 stand: `:Melomotion show` and `show pick` ([[choosing-a-session]]), and keys in Vim notation.

## Consequences

- The layout is rule-based, not free-form. Each rule is a small function in `lyrics.lua`, still pure and tested from hand-written records.
- A song is longer than the old view for the same session, since every part gets a label line and a blank line.
- Paths are shorter, so two files with the same name are only told apart if both appear in the session.
- The thresholds (1 s, 3 s, three repeats, repeats spanning up to eight stays) are constants in `lyrics.lua`, not options.
