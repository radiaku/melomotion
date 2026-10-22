-- Loads this plugin and mini.test, nothing from the user's config.
-- Used by `make test` and by every child Neovim the tests start.
vim.opt.runtimepath:append(vim.fn.getcwd())

if #vim.api.nvim_list_uis() == 0 then
  vim.opt.runtimepath:append(vim.fn.getcwd() .. "/deps/mini.nvim")

  local file, case = vim.env.FILE, vim.env.CASE
  require("mini.test").setup({
    collect = {
      find_files = file and file ~= "" and function()
        return { file }
      end or nil,
      filter_cases = case and case ~= "" and function(c)
        return table.concat(c.desc, " "):find(case, 1, true) ~= nil
      end or nil,
    },
  })
end
