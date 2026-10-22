local M = {}

function M.check()
  vim.health.start("melomotion")

  if vim.fn.has("nvim-0.10") == 1 then
    vim.health.ok("Neovim " .. tostring(vim.version()))
  else
    vim.health.error(
      "Neovim 0.10 or newer is required",
      "vim.on_key only reports the keys you typed from 0.10 on"
    )
  end

  local config = require("melomotion.config")
  if config.error then
    vim.health.error("setup() was given a bad option: " .. config.error)
  else
    vim.health.ok("options are valid")
  end

  local dir = config.get().dir
  if vim.fn.isdirectory(dir) == 0 then
    vim.health.info(dir .. " doesn't exist yet. The first recording creates it.")
  elseif vim.fn.filewritable(dir) == 2 then
    vim.health.ok("recordings go to " .. dir)
  else
    vim.health.error(dir .. " isn't writable")
  end

  local status = require("melomotion").status()
  vim.health.info(status.recording and ("recording to " .. status.path) or "not recording")
end

return M
