local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local function start(opts)
  child.lua(
    [[
      _G.events = {}
      require("melomotion.recorder").start(function(e) table.insert(_G.events, e) end, ...)
    ]],
    { opts }
  )
end

local function events()
  return child.lua_get("_G.events")
end

-- Each argument reaches the child as its own input, with a pause, like separate key presses.
local function press(...)
  child.type_keys(10, ...)
end

local function field(name, list)
  return vim.tbl_map(function(e)
    return e[name]
  end, list or events())
end

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minimal_init.lua" })
      child.lua([[
        local lines = {}
        for i = 1, 100 do lines[i] = ("foo(bar) baz qux %d"):format(i) end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      ]])
      start()
    end,
    post_once = child.stop,
  },
})

T["motions"] = MiniTest.new_set()

T["motions"]["record the keys and where they went"] = function()
  press("2j")
  local e = events()
  eq(#e, 1)
  eq(e[1].kind, "cursor")
  eq(e[1].keys, "2j")
  eq(e[1].mode, "n")
  eq({ e[1].from.line, e[1].to.line }, { 1, 3 })
end

T["motions"]["keep a command's keys together across a pause"] = function()
  press("f", "(")
  eq(field("keys"), { "f(" })
  press("2", "w")
  eq(field("keys"), { "f(", "2w" })
end

T["motions"]["include moving a visual selection"] = function()
  press("v", "j", "<Esc>")
  local e = events()
  eq(#e, 1)
  eq(e[1].keys, "j")
  eq(e[1].mode, "v")
end

T["motions"]["record what you typed, not what a mapping expands to"] = function()
  child.lua([[vim.keymap.set("n", "<Space>g", function() vim.cmd("normal! G") end)]])
  press("<Space>g")
  eq(field("keys"), { "<Space>g" })
end

T["motions"]["include scrolling without moving the cursor"] = function()
  press("50G", "zt")
  eq(field("kind"), { "cursor", "scroll" })
  eq(field("keys"), { "50G", "zt" })
end

T["motions"]["record a search with its pattern"] = function()
  press("/", "qux 3", "<CR>")
  local e = events()
  eq(#e, 1)
  eq(e[1].keys, "/qux 3")
  eq(e[1].to.line, 3)
end

T["motions"]["record an ex command that moves"] = function()
  press(":", "42", "<CR>")
  eq(field("keys"), { ":42" })
end

T["motions"]["drop the keys of commands that move nothing"] = function()
  press(":", "echo 1", "<CR>")
  press("yy")
  press("j")
  eq(field("keys"), { "j" })
end

T["edits"] = MiniTest.new_set()

T["edits"]["are not recorded"] = function()
  press("dw", "x", "p", "J", "u", ">>", "<C-r>")
  eq(events(), {})
end

T["edits"]["in insert mode are not recorded"] = function()
  press("5|", "i", "abc", "<Esc>")
  press("A", "<Esc>", "o", "<Esc>")
  press("w", "i", "<Esc>")
  eq(field("keys"), { "5|", "w" })
end

T["edits"]["don't leak their keys into the next motion"] = function()
  press("d", "w")
  press("j")
  eq(field("keys"), { "j" })
end

T["edits"]["ignore operators that move the cursor"] = function()
  press("3G")
  press("y", "k")
  press("v", "j", "y")
  eq(field("keys"), { "3G", "j" })
end

T["switching"] = MiniTest.new_set()

T["switching"]["windows"] = function()
  press("<C-w>v")
  press("<C-w>w")
  eq(field("kind"), { "window", "window" })
  eq(field("keys"), { "<C-W>v", "<C-W>w" })
end

T["switching"]["buffers"] = function()
  local file = child.lua([[
    local file = vim.fn.tempname() .. ".txt"
    vim.fn.writefile({ "one", "two" }, file)
    vim.cmd.badd(file)
    return file
  ]])
  press(":", "bnext", "<CR>")
  local e = events()
  eq(field("kind", e), { "buffer" })
  eq(e[1].keys, ":bnext")
  eq(vim.fs.basename(e[1].to.file), vim.fs.basename(file))
end

T["switching"]["tabs"] = function()
  press(":", "tabnew", "<CR>")
  press("gt")
  eq(field("kind"), { "tab", "tab" })
  eq(field("keys"), { ":tabnew", "gt" })
end

T["late jumps"] = MiniTest.new_set()

T["late jumps"]["are credited to the keys that asked for them"] = function()
  child.lua([[
    vim.keymap.set("n", "gD", function()
      vim.defer_fn(function() vim.api.nvim_win_set_cursor(0, { 10, 0 }) end, 30)
    end)
  ]])
  press("gD")
  vim.uv.sleep(150)
  local e = events()
  eq(#e, 1)
  eq(e[1].keys, "gD")
  eq(e[1].async, true)
end

T["late jumps"]["after the async window get no keys"] = function()
  child.lua("require('melomotion.recorder').stop()")
  start({ async_window = 20 })
  child.lua([[
    vim.keymap.set("n", "gD", function()
      vim.defer_fn(function() vim.api.nvim_win_set_cursor(0, { 10, 0 }) end, 100)
    end)
  ]])
  press("gD")
  vim.uv.sleep(250)
  local e = events()
  eq(#e, 1)
  eq(e[1].keys, "")
  eq(e[1].async, nil)
end

T["pickers"] = MiniTest.new_set({
  hooks = {
    pre_case = function()
      -- A small stand-in for Telescope: a float in insert mode that opens a file on <CR>.
      child.lua([[
        _G.target = vim.fn.tempname() .. ".txt"
        vim.fn.writefile({ "one", "two", "three" }, _G.target)
        vim.keymap.set("n", "<Space>p", function()
          local buf = vim.api.nvim_create_buf(false, true)
          vim.bo[buf].filetype = "testpicker"
          vim.api.nvim_open_win(buf, true, { relative = "editor", row = 1, col = 1, width = 20, height = 3 })
          vim.cmd("startinsert")
          vim.keymap.set("i", "<CR>", function()
            vim.cmd("stopinsert")
            vim.api.nvim_win_close(0, true)
            vim.cmd.edit(_G.target)
            vim.api.nvim_win_set_cursor(0, { 2, 0 })
          end, { buffer = buf })
          vim.keymap.set("n", "q", function() vim.api.nvim_win_close(0, true) end, { buffer = buf })
        end)
      ]])
    end,
  },
})

T["pickers"]["credit the keys that opened them to where they land"] = function()
  press("<Space>p", "two", "<CR>")
  local e = events()
  eq(#e, 1)
  eq(e[1].kind, "buffer")
  eq(e[1].keys, "<Space>p")
  eq(e[1].via, "testpicker")
  eq(e[1].to.line, 2)
end

T["pickers"]["cancelled record nothing"] = function()
  press("<Space>p", "two", "<Esc>", "q")
  press("j")
  eq(field("keys"), { "j" })
  eq(field("via"), {})
end

T["stop records a movement whose command hasn't ended yet"] = function()
  child.lua([[
    vim.api.nvim_win_set_cursor(0, { 5, 0 })
    vim.api.nvim_exec_autocmds("CursorMoved", {})
    require("melomotion.recorder").stop()
  ]])
  eq(field("kind"), { "cursor" })
end

T["stop"] = function()
  child.lua("require('melomotion.recorder').stop()")
  press("j")
  eq(events(), {})
  eq(
    child.lua("return (pcall(vim.api.nvim_get_autocmds, { group = 'melomotion.recorder' }))"),
    false
  )
end

return T
