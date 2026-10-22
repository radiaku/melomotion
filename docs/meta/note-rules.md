---
title: Note rules
status: stable
tags: [meta]
up: "[[meta]]"
updated: 2026-10-22
---

# Note rules

- **One idea per note.** If a note has two sections that could each stand alone, split it. A note should fit on one screen.
- **Names are unique across `docs/`.** Wikilinks resolve by file name, not path, so `architecture/testing.md` and `development/testing.md` can't both exist. Use kebab-case.
- **Each hub is named after its folder** (`architecture/architecture.md`) and lists every note in that folder. A new note goes into its hub's list.
- **Every note points up.** Its `up:` field ([[frontmatter]]) leads back toward [[index]].
- **Link sideways freely.** Put a link inline where the idea comes up, or under `## Related`. A link to a note that doesn't exist yet is fine: it marks a gap.
- **Renaming means relinking.** Run `grep -rn "\[\[old-name" docs/` and fix every hit.
- **Docs follow code.** When a change makes a note wrong, fix the note in the same commit.
- **Decisions are ADRs.** See [[decisions]] for how they're written and superseded.
