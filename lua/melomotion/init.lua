--- melomotion records how you move around Neovim, not what you edit.
local M = {}

local config = require("melomotion.config")

---@type melomotion.Session?
local session = nil
local timer = nil
local flush_queued = false

local function flush()
  if not session then
    return
  end
  local ok, err = session:flush()
  if not ok then
    vim.notify(
      ("melomotion: could not write %s: %s"):format(session.path, err),
      vim.log.levels.ERROR
    )
  end
end

--- Sets options. Optional: everything works with the defaults.
---@param opts? melomotion.UserConfig
function M.setup(opts)
  local ok, err = config.set(opts)
  if not ok then
    vim.notify("melomotion: " .. err, vim.log.levels.ERROR)
    return
  end
  if config.get().autostart then
    M.start()
  end
end

--- Starts a recording session. Does nothing if one is running.
---@return string? path Session file.
---@return string? err
function M.start()
  if session then
    return session.path
  end
  local cfg = config.get()
  local ok, opened = pcall(require("melomotion.storage").open, cfg.dir)
  if not ok then
    return nil, opened
  end
  session = opened
  session:push({ kind = "start", nvim = tostring(vim.version()), cwd = vim.uv.cwd() })

  require("melomotion.recorder").start(function(event)
    session:push(event)
    if #session.buffer >= cfg.max_buffered and not flush_queued then
      flush_queued = true
      vim.schedule(function()
        flush_queued = false
        flush()
      end)
    end
  end, { async_window = cfg.async_window })

  if cfg.flush_interval > 0 then
    timer = vim.uv.new_timer()
    timer:start(cfg.flush_interval, cfg.flush_interval, vim.schedule_wrap(flush))
  end
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("melomotion", { clear = true }),
    callback = function()
      M.stop()
    end,
  })
  return session.path
end

--- Stops recording and writes everything left.
---@return { path: string, written: integer }? result nil when nothing was recording.
function M.stop()
  if not session then
    return nil
  end
  require("melomotion.recorder").stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  pcall(vim.api.nvim_del_augroup_by_name, "melomotion")
  session:push({ kind = "stop" })
  flush()
  local done = { path = session.path, written = session.written }
  session = nil
  return done
end

--- Writes what's recorded so far and keeps recording.
---@return { path: string, written: integer }? result nil when nothing was recording.
function M.save()
  if not session then
    return nil
  end
  flush()
  return { path = session.path, written = session.written }
end

---@return boolean
function M.is_recording()
  return session ~= nil
end

---@return { recording: boolean, path: string?, written: integer, buffered: integer }
function M.status()
  if not session then
    return { recording = false, written = 0, buffered = 0 }
  end
  return {
    recording = true,
    path = session.path,
    written = session.written,
    buffered = #session.buffer,
  }
end

return M
