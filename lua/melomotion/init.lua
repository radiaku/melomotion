local M = {}

local recorder = require("melomotion.recorder")

function M.start()
  recorder.start()
end

function M.stop()
  recorder.stop()
end

function M.save(path)
  recorder.save(path)
end

-- Optional: define user commands
vim.api.nvim_create_user_command("MelomotionStart", function()
  M.start()
end, {})

vim.api.nvim_create_user_command("MelomotionStop", function()
  M.stop()
end, {})

vim.api.nvim_create_user_command("MelomotionSave", function(opts)
  M.save(opts.args or "/tmp/motions.txt")
end, { nargs = "?" })

return M
