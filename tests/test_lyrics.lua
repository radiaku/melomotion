local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local function at(file, line)
  return { file = file, ft = "", line = line or 1, col = 0, top = 1 }
end

local function move(kind, keys, from, to, extra)
  return vim.tbl_extend("force", { kind = kind, keys = keys, from = from, to = to }, extra or {})
end

-- Cursor moves in one place, one per key.
local function moves_in(place, keys)
  return vim.tbl_map(function(k)
    return move("cursor", k, place, place)
  end, keys)
end

local START = { kind = "start", t = 0, cwd = "/p", nvim = "0.10.4" }

local function render(records, width)
  return child.lua("return require('melomotion.lyrics').render(...)", { records, width or 72 })
end

-- The song without its title, date and the blank line after them.
local function song(records, width)
  return vim.list_slice(render(records, width), 4)
end

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minimal_init.lua" })
    end,
    post_once = child.stop,
  },
})

T["name the parts of the song, each sung from the keys that led there"] = function()
  local a, b, c = at("/p/a.lua"), at("/p/lua/b.lua"), at("/p/c.lua")
  eq(
    song({
      START,
      move("buffer", "<Space>ff", a, b, { via = "TelescopePrompt" }),
      move("cursor", "w", b, b),
      move("window", "<C-W>w", b, c),
      move("cursor", "j", c, c),
      move("window", "<C-W>p", c, b),
    }),
    {
      "[Intro: a.lua]",
      "",
      "[Verse 1: b.lua]",
      "♪ <Space>ff (TelescopePrompt) ~ w ♪",
      "",
      "[Verse 2: c.lua]",
      "♪ <C-W>w ~ j ♪",
      "",
      "[Outro: b.lua]",
      "♪ <C-W>p ♫",
    }
  )
end

T["make a bridge of places you only passed through"] = function()
  local a, b, c, d = at("/p/a.lua"), at("/p/b.lua"), at("/p/c.lua"), at("/p/d.lua")
  local records = { START, move("cursor", "j", a, a) }
  vim.list_extend(records, {
    move("buffer", "<C-L>", a, b),
    move("buffer", "<C-L>", b, c),
    move("buffer", "<C-H>", c, d),
    move("cursor", "k", d, d),
  })
  eq(song(records), {
    "[Intro: a.lua]",
    "♪ j ♪",
    "",
    "[Bridge: b.lua → c.lua]",
    "♪ <C-L>  <C-L> ♪",
    "",
    "[Outro: d.lua]",
    "♪ <C-H> ~ k ♫",
  })
end

T["sing what repeats back to back once, as a chorus"] = function()
  local a, b = at("/p/a.lua"), at("/p/b.lua")
  local records = { START, move("cursor", "j", a, a) }
  for _ = 1, 3 do
    vim.list_extend(records, { move("buffer", "<C-L>", a, b), move("buffer", "<C-H>", b, a) })
  end
  eq(song(records), {
    "[Intro: a.lua]",
    "♪ j ♪",
    "",
    "[Chorus ×3: b.lua ⇄ a.lua]",
    "♪ <C-L>  <C-H> ♫",
  })
end

T["call a verse heard again later a chorus"] = function()
  local a, b = at("/p/a.lua"), at("/p/b.lua")
  local records = { START, move("cursor", "j", a, a) }
  for _, last in ipairs({ "j", "G" }) do
    vim.list_extend(records, {
      move("buffer", "<C-L>", a, b),
      move("cursor", "k", b, b),
      move("buffer", "<C-H>", b, a),
      move("cursor", last, a, a),
    })
  end
  eq(song(records), {
    "[Intro: a.lua]",
    "♪ j ♪",
    "",
    "[Chorus: b.lua]",
    "♪ <C-L> ~ k ♪",
    "",
    "[Verse 1: a.lua]",
    "♪ <C-H> ~ j ♪",
    "",
    "[Chorus: b.lua]",
    "♪ <C-L> ~ k ♪",
    "",
    "[Outro: a.lua]",
    "♪ <C-H> ~ G ♫",
  })
end

T["sing runs of up to three, fold longer ones"] = function()
  local a = at("/p/a.lua")
  local records = { START }
  vim.list_extend(records, moves_in(a, { "j", "j", "j", "k", "k", "k", "k", "/foo", "/foo" }))
  eq(song(records), { "[Verse 1: a.lua]", "♪ j j j k×4 /foo /foo ♫" })
end

T["breathe at a pause and start a new line at a long one"] = function()
  local a = at("/p/a.lua")
  local records = { START }
  -- The pause before the first key doesn't count.
  for _, key in ipairs({ { "j", 4000 }, { "j", 4200 }, { "k", 5400 }, { "k", 5500 } }) do
    table.insert(records, move("cursor", key[1], a, a, { t = key[2] }))
  end
  table.insert(records, move("cursor", "", a, a, { t = 6000 }))
  table.insert(records, move("cursor", "G", a, a, { t = 9500 }))
  table.insert(records, move("cursor", "gg", a, a, { t = 9600 }))
  eq(song(records), { "[Verse 1: a.lua]", "♪ j j, k k ♪", "♪ G gg ♫" })
end

T["wrap lines and labels at the width"] = function()
  local a, b, c = at("/p/a.lua"), at("/p/b.lua"), at("/p/c.lua")
  local records = { START, move("buffer", "<C-L>", a, b), move("buffer", "<C-L>", b, c) }
  vim.list_extend(records, moves_in(c, { "w", "b", "w", "b", "w", "b", "w", "b" }))
  eq(song(records, 14), {
    "[Intro: a.lua",
    "  → b.lua]",
    "♪ <C-L> ♪",
    "",
    "[Outro: c.lua]",
    "♪ <C-L> ~ w",
    "  b w b w b",
    "  w b ♫",
  })
end

T["name places by file name, and keep apart files that share one"] = function()
  local files =
    { at(""), at("/p/a/init.lua"), at("/p/b/init.lua"), at("/x/init.lua"), at("/x/c.lua") }
  local records = { START }
  for i = 2, #files do
    vim.list_extend(records, { move("window", "<C-W>w", files[i - 1], files[i]) })
    vim.list_extend(records, moves_in(files[i], { "j" }))
  end
  local labels = vim.tbl_filter(function(line)
    return vim.startswith(line, "[")
  end, song(records))
  eq(labels, {
    "[Intro: [No Name]]",
    "[Verse 1: a/init.lua]",
    "[Verse 2: b/init.lua]",
    "[Verse 3: /x/init.lua]",
    "[Outro: c.lua]",
  })
end

T["name the song after the place you moved in most, featuring the runner-up"] = function()
  local a, b, c = at("/p/a.lua"), at("/p/b.lua"), at("/p/c.lua")
  local records = { START }
  vim.list_extend(records, moves_in(a, { "j" }))
  table.insert(records, move("window", "<C-W>w", a, b))
  vim.list_extend(records, moves_in(b, { "j", "k", "w" }))
  table.insert(records, move("window", "<C-W>w", b, c))
  vim.list_extend(records, moves_in(c, { "G" }))
  eq(render(records)[1], "♫ b.lua (feat. c.lua)")
  eq(render({ START, moves_in(a, { "j" })[1] })[1], "♫ a.lua")
end

T["date the song and give its length"] = function()
  local a = at("/p/a.lua")
  local function subtitle(last_t)
    local records = { START, moves_in(a, { "j" })[1], { kind = "stop", t = last_t } }
    return render(records)[2]
  end
  eq(subtitle(65000):match("^  .+ %d%d%d%d · %d%d:%d%d · (.+)$"), "1:05")
  eq(subtitle(3725000):match(" · ([%d:]+)$"), "1:02:05")
end

T["say when nothing moved"] = function()
  local lines = render({ START, { kind = "stop", t = 5000 } })
  eq(lines[1], "♫ Untitled")
  eq(vim.list_slice(lines, 3), { "", "(no movement recorded)" })
end

return T
