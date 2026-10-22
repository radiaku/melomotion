---
title: Frontmatter
status: stable
tags: [meta]
up: "[[meta]]"
updated: 2026-10-22
---

# Frontmatter

Every note starts with:

```yaml
---
title: Human-readable title
status: planned
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---
```

- `status` is one of:
  - `planned`: describes intent; no code backs it yet
  - `draft`: code exists but is still changing
  - `stable`: matches the code; change the note together with the code
  - `superseded`: kept for history; links to its replacement
- `up` is the parent hub. Keep the quotes: without them YAML reads `[[x]]` as a nested list.
- `updated` is the date of the last real content change (`YYYY-MM-DD`).
- [[index]] is the only note without `up`.

## Related

- [[note-template]]
