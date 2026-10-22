local M = {}

---@class melomotion.Config
---@field autostart boolean Start recording as soon as setup() runs.
---@field dir string Directory for session files.
---@field flush_interval integer Milliseconds between writes to disk. 0 writes only on save and stop.
---@field max_buffered integer Write early once this many records are waiting.
---@field async_window integer Milliseconds a movement with no keys of its own can still be credited to the last keys that moved nothing, such as an LSP `gd`.

---@class melomotion.UserConfig
---@field autostart? boolean
---@field dir? string
---@field flush_interval? integer
---@field max_buffered? integer
---@field async_window? integer

---@type melomotion.Config
M.defaults = {
  autostart = false,
  dir = vim.fn.stdpath("state") .. "/melomotion",
  flush_interval = 60000,
  max_buffered = 500,
  async_window = 2000,
}

local types = {
  autostart = "boolean",
  dir = "string",
  flush_interval = "number",
  max_buffered = "number",
  async_window = "number",
}

---@type melomotion.Config
local current = vim.deepcopy(M.defaults)

--- The error from the last `set()` call, shown by :checkhealth.
---@type string?
M.error = nil

---@param opts table
---@return string? err
local function validate(opts)
  if type(opts) ~= "table" then
    return "setup() expects a table, got " .. type(opts)
  end
  for key, value in pairs(opts) do
    local want = types[key]
    if not want then
      return ("unknown option '%s'"):format(key)
    end
    if type(value) ~= want then
      return ("option '%s' should be a %s, got %s"):format(key, want, type(value))
    end
    if want == "number" and value < 0 then
      return ("option '%s' can't be negative"):format(key)
    end
  end
end

--- Replaces the current options with `opts` merged over the defaults.
---@param opts? melomotion.UserConfig
---@return boolean ok
---@return string? err
function M.set(opts)
  opts = opts or {}
  M.error = validate(opts)
  if M.error then
    return false, M.error
  end
  current = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts)
  current.dir = vim.fs.normalize(current.dir)
  return true
end

---@return melomotion.Config
function M.get()
  return current
end

return M
