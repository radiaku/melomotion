# melomotion

> Your cursor has been dancing all day. melomotion writes down the song.

melomotion is a Neovim plugin that records **how you move**: motions, jumps,
searches, scrolling, hopping between windows, buffers and tabs, and landing on
files from pickers like Telescope. It politely looks away whenever you edit.

Then it plays your session back as a song:

```text
♫ init.lua (feat. config.lua)
  Thursday 22 Oct 2026 · 09:14 · 3:12

[Intro: init.lua]
♪ j×17 k k k, } } /setup n×4 ♪

[Verse 1: config.lua]
♪ <Space>ff (TelescopePrompt) ~ gg G gg ♪

[Chorus ×3: init.lua ⇄ config.lua]
♪ <C-O>  <C-I> ♪

[Outro: init.lua]
♪ <C-O> ~ j×9 ♫
```

That's seventeen `j`s in a row, and a chorus of `<C-O>` and `<C-I>` sung three
times. melomotion isn't judging. The lyrics are.

## Who's it for?

**The j-hammerer.** You go down 17 lines with 17 presses. You've heard of
`17j`, `}` and `/`, and you mean to try them someday. The lyrics are a mirror,
and the mirror counts.

**The leader-key collector.** You have 140 `<Space>` mappings and use five.
After a week of recording you'll know which five, and maybe which 135 can go.

**The Telescope tourist.** Every file, even the one in the next split, is a
trip through `<Space>ff`. Each landing gets its own verse, picker credited, so
you can count your tickets.

**The coach.** You're teaching someone Vim. Record a session, show them their
verse, then hum `w w w w` until they discover `f`.

**The curious.** You just want to know what your hands do all day. Same.

## What it writes down, and what it doesn't

Writes down:

- the keys you pressed to move (`2j`, `<C-W>v`, `<Space>ff`), as you typed
  them, not what your mappings expand to
- where they took you: file, line, column, top of the screen
- searches with their pattern (`/foo`) and `:` commands that moved you (`:42`)
- the picker you came through, credited to the keys that opened it

Looks away from:

- anything you type in insert mode
- edits, operators and yanks (`dw`, `p`, `>>`, `yk`). That's editing, not
  dancing.
- the text in your buffers, which is never stored

Recordings never leave your machine. They're JSON Lines files under
`stdpath("state")/melomotion/` (`~/.local/state/nvim/melomotion/` on macOS and
Linux). They do include file paths, search patterns and `:` commands, so keep
that in mind before you paste one into a bug report.

It gets along with which-key, Telescope and neo-tree. Nothing is recorded until
you start, and when recording is off it hooks into nothing at all.

## Install

Needs Neovim 0.10 or newer. With lazy.nvim:

```lua
{
  "radiaku/melomotion",
  lazy = false, -- it's tiny at startup: one command and five <Plug> mappings
  opts = {},
}
```

Hacking on a local checkout instead:

```lua
{
  dir = "~/Dev/personal/melomotion",
  name = "melomotion",
  lazy = false,
  opts = {},
}
```

## Use

1. `:Melomotion start`, then go about your day.
2. `:Melomotion show` to hear your song so far. `q` closes it.
3. `:Melomotion stop` when you're done. Quitting Neovim stops it too, and
   nothing is lost.

| Command                 | Does                                        |
| ----------------------- | ------------------------------------------- |
| `:Melomotion start`     | start recording                             |
| `:Melomotion stop`      | stop and write everything                   |
| `:Melomotion toggle`    | start or stop                               |
| `:Melomotion save`      | write what's recorded and keep going        |
| `:Melomotion status`    | which file it's writing to                  |
| `:Melomotion show`      | the current or latest session, as lyrics    |
| `:Melomotion show pick` | choose an older session                     |

melomotion is a guest in your config, so it sets no keymaps. Bring your own:

```lua
vim.keymap.set("n", "<leader>mm", "<Plug>(melomotion-toggle)")
vim.keymap.set("n", "<leader>ms", "<Plug>(melomotion-show)")
```

`:help melomotion` has the options, the Lua API and the record format, if you'd
rather read the sheet music.

## Status

Early, but it works. Recording is tested against real typed input, and `show`
reads it back. No export for other tools yet.

## Develop

`make check` formats, lints and runs the tests. The design notes, with the
reasoning behind every rule the recorder follows, live in
[`docs/`](docs/index.md). Pull requests are welcome, including ones that fix
the jokes.
