-- One JSON Lines file per recording session. Records wait in memory until flush().
local M = {}

---@class melomotion.Session
---@field path string
---@field buffer table[] Records not written yet.
---@field written integer Records written so far.
local Session = {}
Session.__index = Session

local function now_ms()
  local sec, usec = vim.uv.gettimeofday()
  return sec * 1000 + math.floor(usec / 1000)
end

-- Neovim 0.10 escapes every "/" as "\/". When it does, turning "\/" back into "/" is safe
-- and keeps file paths readable. Newer versions don't escape, and then nothing is touched.
local escapes_slash = vim.json.encode("/") == [["\/"]]

local function encode(record)
  local line = vim.json.encode(record)
  return escapes_slash and (line:gsub("\\/", "/")) or line
end

--- Starts a new session file in `dir`. Errors if the directory can't be created.
---@param dir string
---@return melomotion.Session
function M.open(dir)
  vim.fn.mkdir(dir, "p")
  local name = ("%s-%d.jsonl"):format(os.date("%Y%m%d-%H%M%S"), vim.fn.getpid())
  return setmetatable({ path = vim.fs.joinpath(dir, name), buffer = {}, written = 0 }, Session)
end

--- Session files in `dir`, newest first.
---@param dir string
---@return string[]
function M.list(dir)
  local files = vim.fn.glob(vim.fs.joinpath(dir, "*.jsonl"), false, true)
  -- Names start with the date and time, so sorting by name sorts by age.
  table.sort(files, function(a, b)
    return a > b
  end)
  return files
end

--- Reads a session file. A missing file has no records. A line that isn't valid JSON, such
--- as one cut short by a crash, is skipped.
---@param path string
---@return table[]
function M.read(path)
  local records = {}
  local file = io.open(path, "r")
  if not file then
    return records
  end
  for line in file:lines() do
    local ok, record = pcall(vim.json.decode, line)
    if ok and type(record) == "table" then
      records[#records + 1] = record
    end
  end
  file:close()
  return records
end

--- Stamps `record` with the current time and queues it.
---@param record table
function Session:push(record)
  record.t = now_ms()
  self.buffer[#self.buffer + 1] = record
end

--- Appends queued records to the session file.
---@return boolean ok
---@return string? err
function Session:flush()
  if #self.buffer == 0 then
    return true
  end
  local lines = {}
  for i, record in ipairs(self.buffer) do
    lines[i] = encode(record)
  end
  local file, err = io.open(self.path, "a")
  if not file then
    return false, err
  end
  file:write(table.concat(lines, "\n"), "\n")
  file:close()
  self.written = self.written + #self.buffer
  self.buffer = {}
  return true
end

return M
