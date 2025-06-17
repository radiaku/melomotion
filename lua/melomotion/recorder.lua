local M = {}
M.recording = false
M.motion_log = {}

local ns_id = vim.api.nvim_create_namespace("melomotion")


-- internal state for grouping
local last_char = nil
local last_time = nil
local repeat_count = 1
local group_delay = 0.8 -- seconds

local function humanize_key(char)
  if char == "\r" then return "<CR>" end
  if char == "\n" then return "<NL>" end
  if char == "\27" then return "<Esc>" end
  if char == " " then return "<Space>" end
  if char == "\t" then return "<Tab>" end
  if vim.fn.char2nr(char) < 32 then
    return string.format("<C-%s>", string.char(vim.fn.char2nr(char) + 64))
  end
  return char
end

local function flush_last()
  if last_char then
    local display = string.rep(last_char, repeat_count)
    table.insert(M.motion_log, { key = display, time = last_time })
    last_char, last_time, repeat_count = nil, nil, 1
  end
end



function M.start()
  if M.recording then return end
  M.recording = true

  local key_buffer = ""
  local buffer_time = nil
  local buffer_timeout = 0.5 -- adjust as needed

  vim.on_key(function(char)
    local mode = vim.api.nvim_get_mode().mode
    if vim.tbl_contains({ "i", "ic", "ix", "t", "c" }, mode) then return end

    local now = os.clock()
    local display_char = humanize_key(char)

    -- Reset buffer if too much time has passed
    if buffer_time and (now - buffer_time > buffer_timeout) then
      flush_last()
      key_buffer = ""
    end

    buffer_time = now
    key_buffer = key_buffer .. char

    -- Try to match a mapping (this returns string if exists, else "")
    local resolved = vim.fn.maparg(key_buffer, "n")
    if resolved and resolved ~= "" then
      flush_last()
      table.insert(M.motion_log, {
        key = "<map:" .. key_buffer .. ">",
        time = now,
      })
      key_buffer = ""
      return
    end

    -- Wait for more keys if mapping is incomplete
    local possible = vim.fn.mapcheck(key_buffer, "n")
    if possible ~= "" then
      return -- a partial match exists, wait
    end

    -- No mapping matched, treat as normal key
    flush_last()
    last_char = display_char
    last_time = now
    key_buffer = ""
  end, ns_id)
end



function M.stop()
  if not M.recording then return end
  M.recording = false
  vim.on_key(nil, ns_id)
  flush_last() -- capture last group
end

function M.save(filepath)
  if filepath == nil or filepath == "" then
    local state_dir = vim.fn.stdpath("state")
    filepath = state_dir .. "/melomotion.txt"
  end

  vim.fn.mkdir(vim.fn.fnamemodify(filepath, ":h"), "p")

  local f, err = io.open(filepath, "w")
  if not f then
    vim.notify("Melomotion: Failed to save to file:\n" .. err, vim.log.levels.ERROR)
    return
  end

  for _, e in ipairs(M.motion_log) do
    f:write(string.format("%s %.3f\n", e.key, e.time))
  end

  f:close()
  vim.notify("Melomotion: Saved motion log to:\n" .. filepath)
end

return M
