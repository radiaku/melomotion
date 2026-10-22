-- Records movement: the keys you pressed and where they took you. Edits are left out.
--
-- Keys are collected by vim.on_key while a command runs. When the command has finished,
-- end_cycle() (scheduled from the first key) compares where you are with where you were and
-- emits one event. docs/recording/ explains each rule below.
local api = vim.api

local M = {}

local ns = api.nvim_create_namespace("melomotion")
local group = "melomotion.recorder"

-- Caps the keys kept for one command, so a held-down key can't grow the list forever.
local MAX_PENDING = 64
local MOUSE_MOVE = vim.keycode("<MouseMove>")

---@class melomotion.Location
---@field tab integer
---@field win integer
---@field buf integer
---@field tick integer
---@field file string
---@field ft string
---@field line integer
---@field col integer
---@field top integer
---@field unloaded boolean? Its text was freed since, as `:edit` does to a buffer it reuses.

---@class melomotion.State
---@field emit fun(event: table)
---@field async_window integer
---@field last melomotion.Location?
---@field pending (string|string[])[] Raw typed keys, or { text } for a finished command line.
---@field waited integer? Bytes in `pending` when a plugin last waited in getchar() for more.
---@field orphan { keys: string, via: string?, at: number }? Last keys that moved nothing.
---@field via string? Filetype of the float (picker) visited since the last cycle.
---@field skip boolean The cursor moved because of an operator or a mode change, not a motion.
---@field scheduled boolean

---@type melomotion.State?
local state = nil

local function is_float(win)
  return api.nvim_win_get_config(win).relative ~= ""
end

local function is_text_mode(mode)
  local c = mode:sub(1, 1)
  return c == "i" or c == "R" or c == "t"
end

local function is_visual(mode)
  local c = mode:sub(1, 1)
  return c == "v" or c == "V" or c == "\22" or c == "s" or c == "S" or c == "\19"
end

local function short_mode(mode)
  local c = mode:sub(1, 1)
  if c == "\22" then
    return "^V"
  elseif c == "\19" then
    return "^S"
  end
  return c
end

---@return melomotion.Location
local function locate(win)
  local buf = api.nvim_win_get_buf(win)
  local cursor = api.nvim_win_get_cursor(win)
  return {
    tab = api.nvim_win_get_tabpage(win),
    win = win,
    buf = buf,
    tick = api.nvim_buf_get_changedtick(buf),
    file = api.nvim_buf_get_name(buf),
    ft = vim.bo[buf].filetype,
    line = cursor[1],
    col = cursor[2],
    top = vim.fn.line("w0", win),
  }
end

local function public(loc)
  return { file = loc.file, ft = loc.ft, line = loc.line, col = loc.col, top = loc.top }
end

-- Opening a file from an empty, unnamed buffer reuses that buffer, number and all. It's
-- unloaded and renamed, where `:e!` only unloads and `:w name` only renames.
local function same_buffer(from, to)
  return from.buf == to.buf and not (from.unloaded and from.file ~= to.file)
end

local function kind_of(from, to)
  if from.tab ~= to.tab then
    return "tab"
  elseif from.win ~= to.win then
    return "window"
  elseif not same_buffer(from, to) then
    return "buffer"
  elseif from.line ~= to.line or from.col ~= to.col then
    return "cursor"
  elseif from.top ~= to.top then
    return "scroll"
  end
end

local function keys_text(pending)
  local out = {}
  for i, k in ipairs(pending) do
    out[i] = type(k) == "table" and k[1] or vim.fn.keytrans(k)
  end
  return table.concat(out)
end

-- The keys in `pending` as one string, or nil if it holds a command line.
local function raw_keys(pending)
  for _, k in ipairs(pending) do
    if type(k) ~= "string" then
      return nil
    end
  end
  return table.concat(pending)
end

-- A plugin that read keys with getchar(), like which-key, may feed them all back to run them,
-- so they arrive twice. Keys read after its last wait are its own, so flash's `ss` stays.
local function drop_replay(pending, waited)
  local raw = raw_keys(pending)
  if not raw or #raw % 2 == 1 then
    return pending
  end
  local half = #raw / 2
  if waited < half and raw:sub(1, half) == raw:sub(half + 1) then
    return { raw:sub(1, half) }
  end
  return pending
end

local function end_cycle()
  local st = state
  if not st then
    return
  end
  st.scheduled = false

  -- Still inside a command: an operator waiting for its motion, or a command line being typed.
  local mode = api.nvim_get_mode().mode
  if mode:sub(1, 2) == "no" or mode:sub(1, 1) == "c" then
    return
  end

  -- A plugin is waiting in getchar() for the rest of the command.
  if vim.fn.state():find("S", 1, true) then
    st.waited = #(raw_keys(st.pending) or "")
    return
  end

  -- In a picker or popup: keep the keys that opened it for wherever it lands.
  local win = api.nvim_get_current_win()
  if is_float(win) then
    local ft = vim.bo[api.nvim_win_get_buf(win)].filetype
    st.via = ft ~= "" and ft or "float"
    return
  end

  local prev, loc = st.last, locate(win)
  local pending, via, skip, waited = st.pending, st.via, st.skip, st.waited
  st.last, st.pending, st.via, st.skip, st.waited = loc, {}, nil, false, nil
  if not prev then
    return
  end
  if waited then
    pending = drop_replay(pending, waited)
  end

  -- Staying in the same window and buffer, the cursor also moves for edits, operators and
  -- leaving insert or visual mode. None of that is navigation. A picker landing always is.
  if not via and prev.win == loc.win and same_buffer(prev, loc) then
    if skip or prev.tick ~= loc.tick or is_text_mode(mode) then
      return
    end
  end

  local kind = kind_of(prev, loc)
  if not kind then
    -- Nothing moved yet, but the jump may still come (LSP requests answer later).
    if #pending > 0 then
      st.orphan = { keys = keys_text(pending), via = via, at = vim.uv.hrtime() / 1e6 }
    end
    return
  end

  local keys, async = keys_text(pending), nil
  if keys == "" and st.orphan and vim.uv.hrtime() / 1e6 - st.orphan.at <= st.async_window then
    keys, via, async = st.orphan.keys, via or st.orphan.via, true
  end
  st.orphan = nil

  st.emit({
    kind = kind,
    keys = keys,
    mode = short_mode(mode),
    from = public(prev),
    to = public(loc),
    via = via,
    async = async,
  })
end

local function schedule_end()
  local st = state
  if st and not st.scheduled then
    st.scheduled = true
    vim.schedule(end_cycle)
  end
end

local function on_key(_, typed)
  local st = state
  if not st or not typed or typed == "" or typed == MOUSE_MOVE then
    return
  end
  -- Keys typed in insert, replace, terminal, command-line or prompt modes are text.
  local c = api.nvim_get_mode().mode:sub(1, 1)
  if c == "i" or c == "R" or c == "t" or c == "c" or c == "r" then
    return
  end
  if #st.pending < MAX_PENDING then
    st.pending[#st.pending + 1] = typed
  end
  schedule_end()
end

local function on_mode_changed()
  local st = state
  if not st or is_float(api.nvim_get_current_win()) then
    return
  end
  local old, new = vim.v.event.old_mode, vim.v.event.new_mode
  if
    new:sub(1, 2) == "no"
    or (is_text_mode(old) and not is_text_mode(new))
    or (is_visual(old) and not is_visual(new))
  then
    st.skip = true
    schedule_end()
  end
end

local function on_cmdline_leave()
  local st = state
  if not st then
    return
  end
  -- Replace the ":", "/" or "?" you typed with the whole line, so ":42" reads as ":42".
  local ev = vim.v.event
  local t = ev.cmdtype
  if not ev.abort and (t == ":" or t == "/" or t == "?") and st.pending[#st.pending] == t then
    st.pending[#st.pending] = { t .. vim.fn.getcmdline() }
  end
  schedule_end()
end

local function on_win_enter()
  local st = state
  if not st then
    return
  end
  local win = api.nvim_get_current_win()
  if is_float(win) then
    local ft = vim.bo[api.nvim_win_get_buf(win)].filetype
    st.via = ft ~= "" and ft or "float"
  end
  schedule_end()
end

local function on_buf_unload(args)
  local st = state
  if st and st.last and st.last.buf == args.buf then
    st.last.unloaded = true
  end
end

--- Starts recording. `emit` gets one table per movement.
---@param emit fun(event: table)
---@param opts? { async_window?: integer }
function M.start(emit, opts)
  if state then
    return
  end
  opts = opts or {}
  state = {
    emit = emit,
    async_window = opts.async_window or 2000,
    pending = {},
    skip = false,
    scheduled = false,
  }
  local win = api.nvim_get_current_win()
  if not is_float(win) then
    state.last = locate(win)
  end

  local id = api.nvim_create_augroup(group, { clear = true })
  api.nvim_create_autocmd({ "CursorMoved", "WinScrolled", "BufEnter", "TextChanged" }, {
    group = id,
    callback = function()
      schedule_end()
    end,
  })
  api.nvim_create_autocmd("WinEnter", { group = id, callback = on_win_enter })
  api.nvim_create_autocmd("ModeChanged", { group = id, callback = on_mode_changed })
  api.nvim_create_autocmd("CmdlineLeave", { group = id, callback = on_cmdline_leave })
  api.nvim_create_autocmd("BufUnload", { group = id, callback = on_buf_unload })
  vim.on_key(on_key, ns)
end

--- Stops recording and removes every hook. A movement still waiting for its command to end
--- is recorded first.
function M.stop()
  if not state then
    return
  end
  if state.scheduled then
    end_cycle()
  end
  state = nil
  vim.on_key(nil, ns)
  api.nvim_del_augroup_by_name(group)
end

---@return boolean
function M.is_running()
  return state ~= nil
end

return M
