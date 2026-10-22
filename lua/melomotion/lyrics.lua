-- Turns a session's records into lyrics: the keys you moved with, one verse per window or
-- file you were in. Pure: records in, lines out.
local M = {}

local INDENT = "  "
local GAP = "  "

local function width_of(s)
  return vim.api.nvim_strwidth(s)
end

local function duration(ms)
  local s = math.floor(ms / 1000 + 0.5)
  if s < 60 then
    return s .. "s"
  end
  local m = math.floor(s / 60)
  if m < 60 then
    return ("%dm %02ds"):format(m, s % 60)
  end
  return ("%dh %02dm"):format(math.floor(m / 60), m % 60)
end

-- Files under the session's directory are shown relative to it.
local function place(loc, cwd)
  local file = loc.file
  if file == "" then
    return "[No Name]"
  elseif cwd and vim.startswith(file, cwd .. "/") then
    return file:sub(#cwd + 2)
  end
  return vim.fn.fnamemodify(file, ":~")
end

-- Runs of the same keys become one word with a count: `j j j` is `j×3`.
local function fold(words)
  local out, runs = {}, {}
  for _, word in ipairs(words) do
    if out[#out] == word then
      runs[#out] = runs[#out] + 1
    else
      out[#out + 1] = word
      runs[#out] = 1
    end
  end
  for i, word in ipairs(out) do
    if runs[i] > 1 then
      out[i] = ("%s×%d"):format(word, runs[i])
    end
  end
  return out
end

local function wrap(words, width)
  local lines, line = {}, nil
  for _, word in ipairs(words) do
    if line and width_of(line) + #GAP + width_of(word) > width then
      lines[#lines + 1] = line
      line = nil
    end
    line = line and (line .. GAP .. word) or (INDENT .. word)
  end
  lines[#lines + 1] = line
  return lines
end

local function header(start, last_t, width)
  local parts = { "melomotion" }
  if start and start.t then
    parts[#parts + 1] = os.date("%Y-%m-%d %H:%M", math.floor(start.t / 1000))
    parts[#parts + 1] = duration((last_t or start.t) - start.t)
  end
  local text = "── " .. table.concat(parts, " · ") .. " "
  return text .. ("─"):rep(width - width_of(text))
end

local function verse_title(name, move)
  if not move or move.keys == "" then
    return "♪ " .. name
  end
  local via = move.via and (" (" .. move.via .. ")") or ""
  return ("♪ %s   ← %s%s"):format(name, move.keys, via)
end

local switches = { tab = true, window = true, buffer = true }

--- Renders `records` (one session file, decoded) as lines no wider than `width` where the
--- keys allow.
---@param records table[]
---@param width integer
---@return string[]
function M.render(records, width)
  local start, last_t, moves = nil, nil, {}
  for _, r in ipairs(records) do
    last_t = r.t or last_t
    if r.kind == "start" then
      start = r
    elseif r.from and r.to then
      moves[#moves + 1] = r
    end
  end
  local cwd = start and start.cwd
  local lines = { header(start, last_t, width), "" }
  if #moves == 0 then
    lines[#lines + 1] = INDENT .. "(no movement recorded)"
    return lines
  end

  -- The first verse is where you started. Each switch starts the next one.
  local verses = { { title = verse_title(place(moves[1].from, cwd)), words = {} } }
  for _, move in ipairs(moves) do
    if switches[move.kind] then
      verses[#verses + 1] = { title = verse_title(place(move.to, cwd), move), words = {} }
    elseif move.keys ~= "" then
      table.insert(verses[#verses].words, move.keys)
    end
  end

  for i, verse in ipairs(verses) do
    -- Verses with no keys stack, so a run of switches reads as one block.
    if i > 1 and #verses[i - 1].words > 0 then
      lines[#lines + 1] = ""
    end
    lines[#lines + 1] = verse.title
    vim.list_extend(lines, wrap(fold(verse.words), width))
  end
  return lines
end

return M
