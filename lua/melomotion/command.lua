-- :Melomotion subcommands. Kept out of plugin/ so it only loads when used.
local M = {}

M.subcommands = { "start", "stop", "toggle", "save", "status" }

local function info(msg)
  vim.notify("melomotion: " .. msg)
end

local handlers = {}

function handlers.start()
  local melomotion = require("melomotion")
  if melomotion.is_recording() then
    return info("already recording to " .. melomotion.status().path)
  end
  local path, err = melomotion.start()
  if not path then
    return vim.notify("melomotion: could not start: " .. tostring(err), vim.log.levels.ERROR)
  end
  info("recording to " .. path)
end

function handlers.stop()
  local done = require("melomotion").stop()
  if not done then
    return info("not recording")
  end
  info(("stopped, %d records in %s"):format(done.written, done.path))
end

function handlers.toggle()
  if require("melomotion").is_recording() then
    handlers.stop()
  else
    handlers.start()
  end
end

function handlers.save()
  local saved = require("melomotion").save()
  if not saved then
    return info("not recording")
  end
  info(("%d records in %s"):format(saved.written, saved.path))
end

function handlers.status()
  local status = require("melomotion").status()
  if not status.recording then
    return info("not recording")
  end
  info(
    ("recording to %s (%d written, %d waiting)"):format(
      status.path,
      status.written,
      status.buffered
    )
  )
end

---@param sub string?
function M.run(sub)
  local handler = handlers[sub]
  if not handler then
    return vim.notify(
      ("melomotion: unknown subcommand '%s', expected one of: %s"):format(
        tostring(sub),
        table.concat(M.subcommands, ", ")
      ),
      vim.log.levels.ERROR
    )
  end
  handler()
end

---@param lead string
---@return string[]
function M.complete(lead)
  return vim.tbl_filter(function(sub)
    return vim.startswith(sub, lead)
  end, M.subcommands)
end

return M
