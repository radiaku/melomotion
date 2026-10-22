# melomotion

Record how you move around Neovim, not what you edit.

melomotion logs the keys you use to get somewhere and where they took you:
motions, jumps, searches, scrolling, switching windows, buffers and tabs, and
opening files through pickers like Telescope. Edits, insert mode and operators
are left out. Each session is a JSON Lines file you can analyse later.

It's early: recording works, but there's no built-in report yet.

## Install

Requires Neovim 0.10 or newer. With lazy.nvim:

```lua
{
  "radiaku/melomotion",
  lazy = false, -- loading costs one command and four <Plug> mappings
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

| Command              | Does                                        |
| -------------------- | ------------------------------------------- |
| `:Melomotion start`  | start a session                             |
| `:Melomotion stop`   | stop and write it                           |
| `:Melomotion toggle` | start or stop                               |
| `:Melomotion save`   | write what's recorded and keep going        |
| `:Melomotion status` | show the session file                       |

No keymaps are set. To bind one:

```lua
vim.keymap.set("n", "<leader>mm", "<Plug>(melomotion-toggle)")
```

Sessions go to `stdpath("state")/melomotion/`. `:help melomotion` covers the
options and the record format.

## Develop

`make check` formats, lints and runs the tests. The design notes live in
[`docs/`](docs/index.md). Pull requests are welcome.
