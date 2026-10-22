-- Runs at startup for everyone who installs the plugin, so it only defines the command and
-- mappings. Their callbacks load the real code on first use.
if vim.g.loaded_melomotion then
  return
end
vim.g.loaded_melomotion = true

vim.api.nvim_create_user_command("Melomotion", function(opts)
  require("melomotion.command").run(opts.fargs[1])
end, {
  nargs = 1,
  complete = function(lead)
    return require("melomotion.command").complete(lead)
  end,
  desc = "Record how you move around: start, stop, toggle, save, status",
})

for _, sub in ipairs({ "start", "stop", "toggle", "save" }) do
  vim.keymap.set("n", ("<Plug>(melomotion-%s)"):format(sub), function()
    require("melomotion.command").run(sub)
  end, { desc = "melomotion " .. sub })
end
