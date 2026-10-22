---
title: Lyrics view
status: stable
tags: [playback]
up: "[[playback]]"
updated: 2026-10-22
---

# Lyrics view

`:Melomotion show` lays a session out as a song sheet ([[adr-0010-lyrics-as-a-song-sheet]]). Each place you stayed is a part of the song, and the keys you moved with are its lyrics. Here is part of a 25-second session:

```text
♫ neo-tree filesystem [1] (feat. storage.lua)
  Thursday 22 Oct 2026 · 15:54 · 0:25

[Intro: conventions.md]

[Chorus: neo-tree filesystem [1]]
♪ <Space>ef ~ j j ♪

[Verse 1: conventions.md]
♪ <Space>ef ~ j ♪

[Verse 4: neo-tree filesystem [1]]
♪ <C-W>h<C-W>h ~ j, j×8 ♪

[Chorus ×2: conventions.md ⇄ versioning.md]
♪ <C-H>  <C-L> ♪

[Bridge: conventions.md → CONTRIBUTING.md → vimdoc-vs-docs.md]
♪ <C-H>  <C-H>  <C-H> ♪

[Outro: storage.lua]
♪ <Space>fs (TelescopePrompt) ~ j j k k k j ♫
```

## Title

- The song is named after the place with the most typed movements (switches into it count), "feat." the runner-up if it has any. Ties go to the place visited first. A session with no movement is "Untitled".
- The second line has the day, the start time and the length (start to last record) as `m:ss`, or `h:mm:ss`.

## Parts

A stay starts where the session started, and again at every `tab`, `window` or `buffer` movement ([[event-schema]]). Stays are grouped into parts in this order:

1. **Chorus ×n:** the block of stays (up to eight) repeated back to back that covers the most stays. Ties go to the shorter block. It's sung once. A two-stay chorus joins its places with `⇄`.
2. **Verse:** a stay where you moved. If an identical stay (same place, same keys in and inside) appears anywhere else in the session, it's a **Chorus** instead, with no count.
3. **Bridge:** a run of stays where you didn't move. Their places are joined with `→`.
4. With two or more parts, the first and last become the **Intro** and **Outro**, unless they're a chorus. Verses are numbered after that.

## Lyrics

- A line is the keys that took you there, then `~`, then the keys you moved with (`cursor` and `scroll` movements). The picker's filetype follows in parentheses ([[picker-landing]]). The intro has no keys in, so it starts with what you did there.
- Places in a bridge or chorus that you only passed through share one line, their keys two spaces apart.
- A pause of 1 s or more before a key ends a phrase with a comma. 3 s or more starts a new line. The pause before a stay's first key doesn't count.
- Up to three repeats of the same keys are sung out (`k k k`). Four or more fold into `k×4`. Folding stays inside a phrase.
- Each line starts with `♪` and ends with `♪`. The song's last line ends on `♫`. Movements with no keys (a timer, a plugin) are left out.
- Lines and labels wrap at the window's width. Continuation lines are indented two spaces.

## Places

A place is named by its file name. When two files in the session share a name, both are shown relative to the session's `cwd`, or with `~` outside it. A buffer with no name is `[No Name]`.

## Buffer

The buffer is a scratch buffer named `melomotion://<file>`, with filetype `melomotion`. Highlighting is in `syntax/melomotion.lua`: the title, the date, part names, places, notes, counts, `~`, breath commas and picker names each get a group. `q` closes it. Showing the same session again replaces it.
