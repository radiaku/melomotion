local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local function press(...)
  child.type_keys(10, ...)
end

-- Records from the session file in this test's directory.
local function records()
  return child.lua([[
    local files = vim.fn.glob(_G.dir .. "/*.jsonl", false, true)
    if #files == 0 then return {} end
    return vim.tbl_map(vim.json.decode, vim.fn.readfile(files[1]))
  ]])
end

local function kinds()
  return vim.tbl_map(function(r)
    return r.kind
  end, records())
end

local function setup(opts)
  child.lua(
    [[require("melomotion").setup(vim.tbl_extend("force", { dir = _G.dir }, ...))]],
    { opts or {} }
  )
end

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minimal_init.lua" })
      child.lua([[
        _G.dir = vim.fn.tempname()
        _G.notes = {}
        vim.notify = function(msg, level) table.insert(_G.notes, { msg, level }) end
        local lines = {}
        for i = 1, 50 do lines[i] = "line " .. i end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      ]])
    end,
    post_once = child.stop,
  },
})

T["startup loads nothing but the command"] = function()
  eq(child.lua_get("package.loaded['melomotion'] == nil"), true)
  eq(child.fn.exists(":Melomotion"), 2)
end

T["session"] = MiniTest.new_set()

T["session"]["writes start, movement and stop records"] = function()
  setup()
  child.lua("require('melomotion').start()")
  press("2j")
  child.lua("require('melomotion').stop()")
  local r = records()
  eq(kinds(), { "start", "cursor", "stop" })
  eq(r[1].nvim, child.lua_get("tostring(vim.version())"))
  eq(r[2].keys, "2j")
  eq(type(r[2].t), "number")
end

T["session"]["keeps file paths readable"] = function()
  setup()
  child.lua([[
    _G.file = vim.fn.tempname() .. ".txt"
    vim.fn.writefile({ "a", "b" }, _G.file)
    require("melomotion").start()
  ]])
  child.cmd("edit " .. child.lua_get("_G.file"))
  child.lua("require('melomotion').stop()")
  local raw =
    child.lua("return table.concat(vim.fn.readfile(vim.fn.glob(_G.dir .. '/*.jsonl')), '\\n')")
  eq(raw:find("\\/", 1, true), nil)
  eq(raw:find(child.lua_get("vim.fs.basename(_G.file)"), 1, true) ~= nil, true)
end

T["session"]["save writes and keeps recording"] = function()
  setup()
  child.lua("require('melomotion').start()")
  press("j")
  child.lua("require('melomotion').save()")
  eq(kinds(), { "start", "cursor" })
  eq(child.lua_get("require('melomotion').is_recording()"), true)
  press("k")
  child.lua("require('melomotion').stop()")
  eq(kinds(), { "start", "cursor", "cursor", "stop" })
end

T["session"]["writes early when the buffer fills"] = function()
  setup({ max_buffered = 2, flush_interval = 0 })
  child.lua("require('melomotion').start()")
  press("j", "j")
  vim.uv.sleep(50)
  eq(#records() >= 2, true)
end

T["session"]["writes on a timer"] = function()
  setup({ flush_interval = 50 })
  child.lua("require('melomotion').start()")
  press("j")
  vim.uv.sleep(200)
  eq(kinds(), { "start", "cursor" })
end

T["session"]["is written when Neovim exits"] = function()
  setup()
  child.lua("require('melomotion').start()")
  press("j")
  child.cmd("doautocmd VimLeavePre")
  eq(kinds(), { "start", "cursor", "stop" })
end

T["setup"] = MiniTest.new_set()

T["setup"]["rejects bad options"] = function()
  local set = function(opts)
    return child.lua("return { require('melomotion.config').set(...) }", { opts })
  end
  eq(set({ nope = 1 }), { false, "unknown option 'nope'" })
  eq(set({ dir = 1 }), { false, "option 'dir' should be a string, got number" })
  eq(set({ max_buffered = -1 }), { false, "option 'max_buffered' can't be negative" })
  eq(set({ autostart = false }), { true })
end

T["setup"]["reports a bad option instead of throwing"] = function()
  child.lua("require('melomotion').setup({ nope = 1 })")
  eq(child.lua_get("_G.notes[1][1]"), "melomotion: unknown option 'nope'")
end

T["setup"]["autostart starts recording"] = function()
  setup({ autostart = true })
  eq(child.lua_get("require('melomotion').is_recording()"), true)
end

T["command"] = MiniTest.new_set()

T["command"]["starts, reports and stops"] = function()
  setup()
  child.cmd("Melomotion start")
  eq(child.lua_get("require('melomotion').is_recording()"), true)
  child.cmd("Melomotion status")
  child.cmd("Melomotion stop")
  eq(child.lua_get("require('melomotion').is_recording()"), false)
  local notes = child.lua_get("vim.tbl_map(function(n) return n[1] end, _G.notes)")
  eq(#notes, 3)
  eq(vim.startswith(notes[1], "melomotion: recording to "), true)
  eq(vim.startswith(notes[2], "melomotion: recording to "), true)
  eq(vim.startswith(notes[3], "melomotion: stopped, 2 records in "), true)
end

T["command"]["completes subcommands"] = function()
  eq(
    child.fn.getcompletion("Melomotion s", "cmdline"),
    { "start", "stop", "save", "status", "show" }
  )
  eq(child.fn.getcompletion("Melomotion show ", "cmdline"), { "pick" })
  eq(child.fn.getcompletion("Melomotion stop ", "cmdline"), {})
end

T["command"]["rejects unknown subcommands"] = function()
  child.cmd("Melomotion nope")
  eq(vim.startswith(child.lua_get("_G.notes[1][1]"), "melomotion: unknown subcommand 'nope'"), true)
  eq(child.lua_get("_G.notes[1][2]"), child.lua_get("vim.log.levels.ERROR"))
end

T["command"]["rejects arguments a subcommand doesn't take"] = function()
  child.cmd("Melomotion start now")
  child.cmd("Melomotion show pick twice")
  eq(child.lua_get("vim.tbl_map(function(n) return n[1] end, _G.notes)"), {
    "melomotion: bad argument for 'start', it takes none",
    "melomotion: bad argument for 'show', expected pick",
  })
  eq(child.lua_get("require('melomotion').is_recording()"), false)
end

T["command"]["toggles through a <Plug> mapping"] = function()
  setup()
  child.lua([[vim.keymap.set("n", "<F2>", "<Plug>(melomotion-toggle)")]])
  press("<F2>")
  eq(child.lua_get("require('melomotion').is_recording()"), true)
  press("<F2>")
  eq(child.lua_get("require('melomotion').is_recording()"), false)
end

T["show"] = MiniTest.new_set()

-- Writes a session file to the test's directory, with one move per key.
local function write_session(name, keys)
  child.lua(
    [[
      local name, keys = ...
      local at = { file = "/p/a.lua", ft = "lua", line = 1, col = 0, top = 1 }
      local lines = { vim.json.encode({ kind = "start", t = 0, cwd = "/p" }) }
      for _, k in ipairs(keys) do
        table.insert(lines, vim.json.encode({ kind = "cursor", t = 1, keys = k, from = at, to = at }))
      end
      vim.fn.mkdir(_G.dir, "p")
      vim.fn.writefile(lines, _G.dir .. "/" .. name)
    ]],
    { name, keys }
  )
end

local function shown()
  return {
    name = child.api.nvim_buf_get_name(0),
    ft = child.bo.filetype,
    -- Without the title, the date and the blank line after them.
    lines = vim.list_slice(child.api.nvim_buf_get_lines(0, 0, -1, false), 4),
  }
end

T["show"]["opens the session being recorded, including what isn't written yet"] = function()
  setup()
  child.cmd("Melomotion start")
  press("j", "w")
  child.cmd("Melomotion show")
  local view = shown()
  eq(vim.startswith(view.name, "melomotion://"), true)
  eq(view.ft, "melomotion")
  eq(child.b.current_syntax, "melomotion")
  eq(child.bo.modifiable, false)
  eq(view.lines[#view.lines], "♪ j w ♫")
  eq(#records(), 0)
  -- Showing it again replaces the old view.
  child.cmd("wincmd p")
  child.cmd("Melomotion show")
  local views = child.lua([[
    return #vim.tbl_filter(function(b)
      return vim.startswith(vim.api.nvim_buf_get_name(b), "melomotion://")
    end, vim.api.nvim_list_bufs())
  ]])
  eq(views, 1)
end

T["show"]["opens the newest session when not recording"] = function()
  setup()
  write_session("20250101-090000-1.jsonl", { "k" })
  write_session("20260101-090000-1.jsonl", { "gg" })
  child.cmd("Melomotion show")
  eq(shown().lines, { "[Verse 1: a.lua]", "♪ gg ♫" })
end

T["show"]["pick lets you choose a session"] = function()
  setup()
  write_session("20250101-090000-1.jsonl", { "k" })
  write_session("20260101-090000-1.jsonl", { "gg" })
  child.lua([[
    vim.ui.select = function(items, opts, choose)
      _G.labels = vim.tbl_map(opts.format_item, items)
      choose(items[2])
    end
  ]])
  child.cmd("Melomotion show pick")
  eq(child.lua_get("_G.labels"), { "2026-01-01 09:00:00", "2025-01-01 09:00:00" })
  eq(shown().lines, { "[Verse 1: a.lua]", "♪ k ♫" })
end

T["show"]["says when there are no recordings"] = function()
  setup()
  child.cmd("Melomotion show")
  child.cmd("Melomotion show pick")
  local notes = child.lua_get("vim.tbl_map(function(n) return n[1] end, _G.notes)")
  eq(#notes, 2)
  eq(vim.startswith(notes[1], "melomotion: no recordings yet in "), true)
  eq(notes[1], notes[2])
end

T["show"]["closes with q"] = function()
  setup()
  write_session("20260101-090000-1.jsonl", { "gg" })
  child.cmd("Melomotion show")
  eq(#child.api.nvim_list_wins(), 2)
  press("q")
  eq(#child.api.nvim_list_wins(), 1)
  eq(vim.startswith(child.api.nvim_buf_get_name(0), "melomotion://"), false)
end

T["help tags resolve"] = function()
  child.cmd("helptags doc")
  child.cmd("help melomotion-config")
  eq(vim.fs.basename(child.api.nvim_buf_get_name(0)), "melomotion.txt")
end

T["health check passes"] = function()
  setup()
  child.cmd("checkhealth melomotion")
  local text = table.concat(child.lua_get("vim.api.nvim_buf_get_lines(0, 0, -1, false)"), "\n")
  eq(text:find("ERROR", 1, true), nil)
  eq(text:find("OK Neovim", 1, true) ~= nil, true)
end

return T
