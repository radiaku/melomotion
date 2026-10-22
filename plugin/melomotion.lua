-- Runs at startup for everyone who installs the plugin, so it only defines the command and
-- mappings. Their callbacks load the real code on first use.
if vim.g.loaded_melomotion then
  return
end
vim.g.loaded_melomotion = true

vim.api.nvim_create_user_command("Melomotion", function(opts)
  require("melomotion.command").run(unpack(opts.fargs))
end, {
  nargs = "+",
  complete = function(lead, line)
    return require("melomotion.command").complete(lead, line)
  end,
  desc = "Record how you move around: start, stop, toggle, save, status, show",
})

for _, sub in ipairs({ "start", "stop", "toggle", "save", "show" }) do
  vim.keymap.set("n", ("<Plug>(melomotion-%s)"):format(sub), function()
    require("melomotion.command").run(sub)
  end, { desc = "melomotion " .. sub })
end
