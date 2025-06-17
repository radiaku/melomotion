local M = {}
M.recording = false
M.motion_log = {}

local ns_id = vim.api.nvim_create_namespace("melomotion")

function M.start()
  if M.recording then return end
  M.recording = true

  local raw_buffer = ""
  local buffer_time = nil
  local buffer_timeout = 0.4 -- seconds

  vim.on_key(function(char)
    local mode = vim.api.nvim_get_mode().mode
    if vim.tbl_contains({ "i", "ic", "ix", "t", "c" }, mode) then return end

    local now = os.clock()
    raw_buffer = raw_buffer .. char

    -- local char_decoded = vim.fn.keytrans(char)
    -- vim.notify(("[melomotion] individual char_decoded: %s"):format(vim.inspect(char_decoded)))

    local decoded = vim.fn.keytrans(raw_buffer)
    -- vim.notify(("[melomotion] char: %s"):format(vim.inspect(char)))
    -- vim.notify(("[melomotion] raw_buffer: %s"):format(vim.inspect(raw_buffer)))
    -- vim.notify(("[melomotion] decoded: %s"):format(vim.inspect(decoded)))

    if decoded:match("<t_") then
      -- vim.notify("[melomotion] ⛔ Skipping Plug mapping: " .. vim.inspect(decoded))
      raw_buffer = ""
     return
    end

    if buffer_time and (now - buffer_time > buffer_timeout) then
      -- vim.notify("[melomotion] 🟡 Flushing buffer due to timeout")

      if #decoded > 0 then
        table.insert(M.motion_log, {
          key = decoded,
          time = buffer_time
        })
      end
      raw_buffer = ""
    end

    buffer_time = now
  end, ns_id)

  M._flush_buffer = function()
    if raw_buffer and #raw_buffer > 0 then
      local decoded = vim.fn.keytrans(raw_buffer)
      -- vim.notify("[melomotion] 🔵 Final flush on stop/save")
      -- vim.notify(("[melomotion] decoded flush: %s"):format(vim.inspect(decoded)))

      table.insert(M.motion_log, {
        key = decoded,
        time = buffer_time
      })
    end
    raw_buffer = ""
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

  local f, err = io.open(filepath, "a")
  if not f then
    vim.notify("Melomotion: Failed to save to file:\n" .. err, vim.log.levels.ERROR)
    return
  end

  for _, e in ipairs(M.motion_log) do
    f:write(string.format("%s %.3f\n", e.key, e.time))
  end

  f:close()
  vim.notify("Melomotion: Saved motion log to:\n" .. filepath)

  M.stop()
end

return M
