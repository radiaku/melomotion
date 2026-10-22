---
title: Recording cost
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Recording cost

`vim.on_key` runs on every key press, so anything slow there shows up as typing lag.

- **Per key:** `on_key` makes one `nvim_get_mode()` call, appends to a list (capped at 64 keys per command), and schedules at most one callback per command.
- **Per command:** `end_cycle()` takes a location snapshot of about ten API calls. It does no I/O.
- **Autocommands:** they only set the scheduled flag.
- **Disk:** writes happen in `storage.flush()`, on save, stop and `VimLeavePre`, every `flush_interval`, or when `max_buffered` records are waiting. Even that last case is scheduled, never done inline.
- **When stopped:** no hooks exist at all. `vim.on_key(nil, ns)` runs and the augroup is deleted. A test checks this.

## Related

- [[lazy-loading]]: the same idea applied to startup
- [[command-cycle]]
