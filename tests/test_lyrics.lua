local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local function at(file, line)
  return { file = file, ft = "", line = line or 1, col = 0, top = 1 }
end

local function move(kind, keys, from, to, extra)
  return vim.tbl_extend("force", { kind = kind, keys = keys, from = from, to = to }, extra or {})
end

local START = { kind = "start", t = 0, cwd = "/p", nvim = "0.10.4" }

-- The lyrics without their header line.
local function render(records, width)
  local lines =
    child.lua("return require('melomotion.lyrics').render(...)", { records, width or 72 })
  return vim.list_slice(lines, 2)
end

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minimal_init.lua" })
    end,
    post_once = child.stop,
  },
})

T["start a verse at each switch, named by the keys that led there"] = function()
  local a, b = at("/p/a.lua"), at("/p/lua/b.lua")
  eq(
    render({
      START,
      move("cursor", "j", a, a),
      move("buffer", "<Space>ff", a, b, { via = "TelescopePrompt" }),
      move("cursor", "w", b, b),
    }),
    { "", "♪ a.lua", "  j", "", "♪ lua/b.lua   ← <Space>ff (TelescopePrompt)", "  w" }
  )
end

T["fold runs of the same keys"] = function()
  local a = at("/p/a.lua")
  local moves = { START }
  for _, keys in ipairs({ "j", "j", "j", "k", "j", "/foo", "/foo" }) do
    moves[#moves + 1] = move("cursor", keys, a, a)
  end
  eq(render(moves), { "", "♪ a.lua", "  j×3  k  j  /foo×2" })
end

T["wrap a verse at the width"] = function()
  local a = at("/p/a.lua")
  local moves = { START }
  for _, keys in ipairs({ "w", "b", "w", "b", "w", "b" }) do
    moves[#moves + 1] = move("cursor", keys, a, a)
  end
  eq(render(moves, 10), { "", "♪ a.lua", "  w  b  w", "  b  w  b" })
end

T["stack switches with no keys between them"] = function()
  local a, b = at("/p/a.lua"), at("/p/b.lua")
  eq(render({ START, move("buffer", "<C-L>", a, b), move("buffer", "<C-H>", b, a) }), {
    "",
    "♪ a.lua",
    "♪ b.lua   ← <C-L>",
    "♪ a.lua   ← <C-H>",
  })
end

T["leave out movements nothing typed caused"] = function()
  local a, b = at("/p/a.lua"), at("/p/b.lua")
  eq(
    render({ START, move("cursor", "", a, a), move("window", "", a, b) }),
    { "", "♪ a.lua", "♪ b.lua" }
  )
end

T["name buffers without a file and files outside the directory"] = function()
  local none, other = at(""), at("/elsewhere/c.lua")
  eq(render({ START, move("window", "<C-W>w", none, other) }), {
    "",
    "♪ [No Name]",
    "♪ /elsewhere/c.lua   ← <C-W>w",
  })
end

T["say when nothing moved"] = function()
  eq(render({ START, { kind = "stop", t = 5000 } }), { "", "  (no movement recorded)" })
end

T["head the lyrics with the date and length"] = function()
  local stop = { kind = "stop", t = 65000 }
  local header =
    child.lua("return require('melomotion.lyrics').render(...)[1]", { { START, stop }, 60 })
  local rule = header:match("^── melomotion · %d%d%d%d%-%d%d%-%d%d %d%d:%d%d · 1m 05s (.+)$")
  eq((rule:gsub("─", "")), "")
  eq(child.fn.strwidth(header), 60)
end

return T
