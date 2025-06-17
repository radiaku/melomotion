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
  local buffer_timeout = 0.4  -- shorter timeout

  vim.on_key(function(char)
    local mode = vim.api.nvim_get_mode().mode
    if vim.tbl_contains({ "i", "ic", "ix", "t", "c" }, mode) then return end

    local now = os.clock()
    local display_char = humanize_key(char)

    -- If delay between keys is too long, flush buffer
    if buffer_time and (now - buffer_time > buffer_timeout) then
      if #key_buffer > 0 then
        table.insert(M.motion_log, {
          key = key_buffer,
          time = buffer_time
        })
      end
      key_buffer = ""
    end

    key_buffer = key_buffer .. display_char
    buffer_time = now
  end, ns_id)

  -- flush on stop
  M._flush_buffer = function()
    if key_buffer and #key_buffer > 0 then
      local leader = vim.g.mapleader or "\\"
      local display = key_buffer

      if display:sub(1, #leader) == leader then
        display = "<leader>" .. display:sub(#leader + 1)
      end

      table.insert(M.motion_log, {
        key = display,
        time = buffer_time
      })
    end
    key_buffer = ""
  end
end


function M.stop()
  if not M.recording then return end
  M.recording = false
  vim.on_key(nil, ns_id)
  if M._flush_buffer then M._flush_buffer() end
end

function M.save(filepath)
  if filepath == nil or filepath == "" then
    local state_dir = vim.fn.stdpath("state")
    filepath = state_dir .. "/melomotion.txt"
  end

  vim.fn.mkdir(vim.fn.fnamemodify(filepath, ":h"), "p")

  local f, err = io.open(filepath, "a+")
  if not f then
    vim.notify("Melomotion: Failed to save to file:\n" .. err, vim.log.levels.ERROR)
    return
  end

  for _, e in ipairs(M.motion_log) do
    f:write(string.format("%s %.3f\n", e.key, e.time))
  end

  f:close()
  vim.notify("Melomotion: Saved motion log to:\n" .. filepath)

  -- 🛑 Automatically stop recording after saving
  M.stop()
end

return M
