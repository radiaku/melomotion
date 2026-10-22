# melomotion

Record how you move around Neovim, not what you edit.

melomotion logs the keys you use to get somewhere and where they took you:
motions, jumps, searches, scrolling, switching windows, buffers and tabs, and
opening files through pickers like Telescope. Edits, insert mode and operators
are left out. Each session is a JSON Lines file you can analyse later.

`:Melomotion show` reads a session back as lyrics: the keys you moved with,
one verse per file or window you were in.

## Install

Requires Neovim 0.10 or newer. With lazy.nvim:

```lua
{
  "radiaku/melomotion",
  lazy = false, -- loading costs one command and five <Plug> mappings
  opts = {},
}
```

Working on a local checkout:

```lua
{
  dir = "~/Dev/personal/melomotion",
  name = "melomotion",
  lazy = false,
  opts = {},
}
```

## Use

| Command                 | Does                                 |
| ----------------------- | ------------------------------------ |
| `:Melomotion start`     | start a session                      |
| `:Melomotion stop`      | stop and write it                    |
| `:Melomotion toggle`    | start or stop                        |
| `:Melomotion save`      | write what's recorded and keep going |
| `:Melomotion status`    | show the session file                |
| `:Melomotion show`      | show the latest session as lyrics    |
| `:Melomotion show pick` | choose a session to show             |

No keymaps are set. To bind one:

```lua
vim.keymap.set("n", "<leader>mm", "<Plug>(melomotion-toggle)")
vim.keymap.set("n", "<leader>ms", "<Plug>(melomotion-show)")
```

Sessions go to `stdpath("state")/melomotion/`. `:help melomotion` covers the
options and the record format.

## Develop

`make check` formats, lints and runs the tests. The design notes live in
[`docs/`](docs/index.md). Pull requests are welcome.
