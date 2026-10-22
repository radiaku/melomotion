-- Turns a session's records into a song sheet: each place you stayed is a part of the song
-- and the keys you moved with are its lyrics. Pure: records in, lines out.
local M = {}

-- A pause this long before a key is a breath (a comma). This long starts a new line.
local BREATH_MS = 1000
local NEW_LINE_MS = 3000
-- Runs this long are sung out (`j j j`). Longer ones fold into one word (`j×4`).
local SUNG_RUN = 3
-- The most stays a back-to-back repeat can span.
local MAX_BLOCK = 8

local switches = { tab = true, window = true, buffer = true }

local function width_of(s)
  return vim.api.nvim_strwidth(s)
end

-- How long a session ran, as on a track list: 0:25, 3:07, 1:02:05.
local function song_length(ms)
  local s = math.max(0, math.floor(ms / 1000 + 0.5))
  local h, m = math.floor(s / 3600), math.floor(s / 60) % 60
  if h > 0 then
    return ("%d:%02d:%02d"):format(h, m, s % 60)
  end
  return ("%d:%02d"):format(m, s % 60)
end

local function header(song, start, last_t)
  local lines = { "♫ " .. song }
  if start and start.t then
    local s = math.floor(start.t / 1000)
    local day = ("%s %d %s"):format(
      os.date("%A", s),
      tonumber(os.date("%d", s)),
      os.date("%b %Y", s)
    )
    local length = song_length((last_t or start.t) - start.t)
    lines[2] = ("  %s · %s · %s"):format(day, os.date("%H:%M", s), length)
  end
  lines[#lines + 1] = ""
  return lines
end

-- Splits the moves into stays: where you started, then one per switch. A stay has the keys
-- that took you there (`entry`) and the keys you moved with while there (`words`), each with
-- the pause before it.
local function stays_of(moves, start_t)
  local first = moves[1]
  local t = start_t or first.t or 0
  local stay = { file = first.from.file, entry = "", words = {} }
  local stays = { stay }
  for _, move in ipairs(moves) do
    local pause = (move.t or t) - t
    t = move.t or t
    if switches[move.kind] then
      stay = { file = move.to.file, entry = move.keys, via = move.via, words = {} }
      stays[#stays + 1] = stay
    elseif move.keys ~= "" then
      table.insert(stay.words, { keys = move.keys, pause = pause })
    end
  end
  for _, s in ipairs(stays) do
    local keys = vim.tbl_map(function(word)
      return word.keys
    end, s.words)
    s.key = table.concat({ s.file, s.entry, s.via or "", table.concat(keys, "\31") }, "\30")
  end
  return stays
end

-- Names a place after its file. Files that share a name are shown relative to the session's
-- directory, or with `~`, to keep them apart.
local function namer(stays, cwd)
  local count, seen = {}, {}
  for _, stay in ipairs(stays) do
    if not seen[stay.file] then
      seen[stay.file] = true
      local tail = vim.fn.fnamemodify(stay.file, ":t")
      count[tail] = (count[tail] or 0) + 1
    end
  end
  return function(file)
    local tail = vim.fn.fnamemodify(file, ":t")
    if file == "" then
      return "[No Name]"
    elseif tail ~= "" and count[tail] == 1 then
      return tail
    elseif cwd and vim.startswith(file, cwd .. "/") then
      return file:sub(#cwd + 2)
    end
    return vim.fn.fnamemodify(file, ":~")
  end
end

-- The song is named after the place you moved in most, featuring the runner-up.
local function song_of(stays, moved, name)
  local top, second
  local seen = {}
  for _, stay in ipairs(stays) do
    local file = stay.file
    if not seen[file] then
      seen[file] = true
      local n = moved[file] or 0
      if not top or n > (moved[top] or 0) then
        top, second = file, top
      elseif not second or n > (moved[second] or 0) then
        second = file
      end
    end
  end
  if second and (moved[second] or 0) > 0 then
    return ("%s (feat. %s)"):format(name(top), name(second))
  end
  return name(top)
end

-- The most stays covered by one block repeated back to back from stay `i`: `k` stays, `r`
-- times. Ties go to the shorter block.
local function repeat_at(stays, i)
  local best_k, best_r = 1, 1
  for k = 1, math.min(MAX_BLOCK, math.floor((#stays - i + 1) / 2)) do
    local r = 1
    while i + (r + 1) * k - 1 <= #stays do
      local same = true
      for o = 0, k - 1 do
        if stays[i + o].key ~= stays[i + r * k + o].key then
          same = false
          break
        end
      end
      if not same then
        break
      end
      r = r + 1
    end
    if r > 1 and k * r > best_k * best_r then
      best_k, best_r = k, r
    end
  end
  return best_k, best_r
end

-- Groups stays into the parts of a song. What repeats back to back is a chorus, sung once
-- with its count. A stay where you moved is a verse, and a chorus if it's heard again later.
-- Places you only passed through make a bridge. The first and last parts are the intro and
-- outro unless they're a chorus.
local function sections_of(stays)
  local sections, i = {}, 1
  while i <= #stays do
    local k, r = repeat_at(stays, i)
    local last = sections[#sections]
    if r > 1 then
      sections[#sections + 1] =
        { part = "Chorus", stays = vim.list_slice(stays, i, i + k - 1), times = r }
      i = i + k * r
    else
      local stay = stays[i]
      if #stay.words > 0 then
        sections[#sections + 1] = { part = "Verse", stays = { stay }, times = 1 }
      elseif last and last.part == "Bridge" then
        table.insert(last.stays, stay)
      else
        sections[#sections + 1] = { part = "Bridge", stays = { stay }, times = 1 }
      end
      i = i + 1
    end
  end

  local heard = {}
  for _, stay in ipairs(stays) do
    heard[stay.key] = (heard[stay.key] or 0) + 1
  end
  for _, section in ipairs(sections) do
    if section.part == "Verse" and heard[section.stays[1].key] > 1 then
      section.part = "Chorus"
    end
  end
  if #sections > 1 then
    for _, section in ipairs({ sections[1], sections[#sections] }) do
      if section.part ~= "Chorus" then
        section.part = section == sections[1] and "Intro" or "Outro"
      end
    end
  end
  local verse = 0
  for _, section in ipairs(sections) do
    if section.part == "Verse" then
      verse = verse + 1
      section.part = "Verse " .. verse
    end
  end
  return sections
end

-- Runs longer than SUNG_RUN fold into one word: `j×7`.
local function sing(keys)
  local out, i = {}, 1
  while i <= #keys do
    local j = i
    while keys[j + 1] == keys[i] do
      j = j + 1
    end
    if j - i + 1 > SUNG_RUN then
      out[#out + 1] = ("%s×%d"):format(keys[i], j - i + 1)
    else
      for _ = i, j do
        out[#out + 1] = keys[i]
      end
    end
    i = j + 1
  end
  return out
end

-- A stay's words as lyric lines, each a list of `{ sep, text }` tokens. A breath ends a
-- phrase with a comma, and a long pause starts a new line.
local function phrase(words)
  local lines = {}
  for i, word in ipairs(words) do
    if i == 1 or word.pause >= NEW_LINE_MS then
      lines[#lines + 1] = { {} }
    elseif word.pause >= BREATH_MS then
      table.insert(lines[#lines], {})
    end
    local line = lines[#lines]
    table.insert(line[#line], word.keys)
  end
  return vim.tbl_map(function(phrases)
    local tokens = {}
    for p, keys in ipairs(phrases) do
      local sung = sing(keys)
      for w, word in ipairs(sung) do
        local breath = w == #sung and p < #phrases
        tokens[#tokens + 1] = { sep = " ", text = breath and word .. "," or word }
      end
    end
    return tokens
  end, lines)
end

-- The lyric lines for a part's stays. Each starts with the keys that took you there, then
-- `~` and the keys you moved with. Places you only passed through share a line.
local function lyrics_of(stays)
  local lines, passing = {}, nil
  for _, stay in ipairs(stays) do
    local entry = stay.entry ~= "" and stay.entry or nil
    if entry and stay.via then
      entry = ("%s (%s)"):format(entry, stay.via)
    end
    if #stay.words == 0 then
      if entry then
        if not passing then
          passing = {}
          lines[#lines + 1] = passing
        end
        passing[#passing + 1] = { sep = "  ", text = entry }
      end
    else
      passing = nil
      local sung = phrase(stay.words)
      if entry then
        table.insert(sung[1], 1, { sep = " ", text = "~" })
        table.insert(sung[1], 1, { sep = " ", text = entry })
      end
      vim.list_extend(lines, sung)
    end
  end
  return lines
end

-- `[Part: place]`, with places in the order you visited them.
local function label(section, name)
  local part = section.part
  if section.times > 1 then
    part = ("%s ×%d"):format(part, section.times)
  end
  local join = (section.times > 1 and #section.stays == 2) and "⇄ " or "→ "
  local tokens = {}
  for i, stay in ipairs(section.stays) do
    local lead = i == 1 and ("[%s: "):format(part) or join
    tokens[i] = { sep = " ", text = lead .. name(stay.file) }
  end
  tokens[#tokens].text = tokens[#tokens].text .. "]"
  return tokens
end

-- Lays tokens out after `lead`, breaking before one that would pass `width`. Lines after the
-- first start with `cont`.
local function wrap(tokens, lead, cont, width)
  local lines, line = {}, lead .. tokens[1].text
  for i = 2, #tokens do
    local token = tokens[i]
    if width_of(line) + #token.sep + width_of(token.text) > width then
      lines[#lines + 1] = line
      line = cont .. token.text
    else
      line = line .. token.sep .. token.text
    end
  end
  lines[#lines + 1] = line
  return lines
end

--- Renders `records` (one session file, decoded) as a song sheet no wider than `width`
--- where the keys allow.
---@param records table[]
---@param width integer
---@return string[]
function M.render(records, width)
  local start, last_t, moves, moved = nil, nil, {}, {}
  for _, r in ipairs(records) do
    last_t = r.t or last_t
    if r.kind == "start" then
      start = r
    elseif r.from and r.to then
      moves[#moves + 1] = r
      if r.keys ~= "" then
        moved[r.to.file] = (moved[r.to.file] or 0) + 1
      end
    end
  end
  if #moves == 0 then
    local lines = header("Untitled", start, last_t)
    lines[#lines + 1] = "(no movement recorded)"
    return lines
  end

  local stays = stays_of(moves, start and start.t)
  local name = namer(stays, start and start.cwd)
  local lines = header(song_of(stays, moved, name), start, last_t)
  local sections = sections_of(stays)
  for i, section in ipairs(sections) do
    if i > 1 then
      lines[#lines + 1] = ""
    end
    vim.list_extend(lines, wrap(label(section, name), "", "  ", width))
    local sung = lyrics_of(section.stays)
    for j, tokens in ipairs(sung) do
      -- Leave room for the closing note. The song's last line ends on ♫.
      local wrapped = wrap(tokens, "♪ ", "  ", width - 2)
      local note = (i == #sections and j == #sung) and " ♫" or " ♪"
      wrapped[#wrapped] = wrapped[#wrapped] .. note
      vim.list_extend(lines, wrapped)
    end
  end
  return lines
end

return M
