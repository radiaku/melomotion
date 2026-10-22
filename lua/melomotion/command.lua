-- :Melomotion subcommands. Kept out of plugin/ so it only loads when used.
local M = {}

M.subcommands = { "start", "stop", "toggle", "save", "status", "show" }

-- Arguments a subcommand accepts after its name.
M.arguments = { show = { "pick" } }

local function info(msg)
  vim.notify("melomotion: " .. msg)
end

local function fail(msg)
  vim.notify("melomotion: " .. msg, vim.log.levels.ERROR)
end

-- "20261022-152336-53597.jsonl" reads as "2026-10-22 15:23:36".
local function session_label(path)
  local name = vim.fs.basename(path)
  local y, mo, d, h, mi, s = name:match("^(%d%d%d%d)(%d%d)(%d%d)%-(%d%d)(%d%d)(%d%d)")
  local label = y and ("%s-%s-%s %s:%s:%s"):format(y, mo, d, h, mi, s) or name
  if path == require("melomotion").status().path then
    label = label .. " (recording)"
  end
  return label
end

-- Shows a session's lyrics in a scratch buffer along the bottom. `q` closes it.
local function open_lyrics(records, path)
  local name = "melomotion://" .. vim.fs.basename(path)
  for _, old in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(old) == name then
      vim.api.nvim_buf_delete(old, { force = true })
    end
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  local win = vim.api.nvim_open_win(buf, true, { split = "below", win = -1 })
  local lines = require("melomotion.lyrics").render(records, vim.api.nvim_win_get_width(win) - 2)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(buf, name)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "melomotion"
  vim.api.nvim_win_set_height(win, math.max(3, math.min(#lines, math.floor(vim.o.lines / 2))))
  vim.keymap.set("n", "q", "<Cmd>bwipeout<CR>", { buffer = buf, nowait = true, desc = "Close" })
end

local handlers = {}

function handlers.start()
  local melomotion = require("melomotion")
  if melomotion.is_recording() then
    return info("already recording to " .. melomotion.status().path)
  end
  local path, err = melomotion.start()
  if not path then
    return fail("could not start: " .. tostring(err))
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

function handlers.show(arg)
  local melomotion = require("melomotion")
  if arg == "pick" then
    local sessions = melomotion.sessions()
    if #sessions == 0 then
      return info("no recordings yet in " .. require("melomotion.config").get().dir)
    end
    return vim.ui.select(
      sessions,
      { prompt = "melomotion session", format_item = session_label },
      function(path)
        if path then
          open_lyrics(melomotion.read(path), path)
        end
      end
    )
  end
  local records, path = melomotion.read()
  if not records then
    return info("no recordings yet in " .. require("melomotion.config").get().dir)
  end
  open_lyrics(records, path)
end

---@param sub string?
---@param arg string?
function M.run(sub, arg, ...)
  local handler = handlers[sub]
  if not handler then
    return fail(
      ("unknown subcommand '%s', expected one of: %s"):format(
        tostring(sub),
        table.concat(M.subcommands, ", ")
      )
    )
  end
  local allowed = M.arguments[sub] or {}
  if select("#", ...) > 0 or (arg and not vim.tbl_contains(allowed, arg)) then
    local expected = #allowed > 0 and ("expected " .. table.concat(allowed, " or "))
      or "it takes none"
    return fail(("bad argument for '%s', %s"):format(sub, expected))
  end
  handler(arg)
end

--- Completes subcommand names, then their arguments.
---@param lead string
---@param line? string The command line so far.
---@return string[]
function M.complete(lead, line)
  local words = vim.split(vim.trim(line or ""), "%s+")
  local before = #words - (lead == "" and 0 or 1)
  local candidates = before <= 1 and M.subcommands or M.arguments[words[2]] or {}
  return vim.tbl_filter(function(word)
    return vim.startswith(word, lead)
  end, candidates)
end

return M
