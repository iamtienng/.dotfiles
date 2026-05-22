-- Autocmds are automatically loaded on the VeryLazy event.
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup("user-highlight-yank", { clear = true })
autocmd("TextYankPost", {
  group = yank_group,
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 120 })
  end,
})

vim.filetype.add({
  extension = {
    templ = "templ",
    jinja = "jinja",
    jinja2 = "jinja",
    j2 = "jinja",
  },
  pattern = {
    ["%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
  },
})

local format_group = augroup("user-format-on-save", { clear = true })

autocmd("BufWritePre", {
  group = format_group,
  pattern = "*.go",
  desc = "Format Go files with goimports",
  callback = function()
    local ok, go_format = pcall(require, "go.format")
    if ok then
      go_format.goimports()
    else
      vim.lsp.buf.format({ async = false })
    end
  end,
})

autocmd("BufWritePre", {
  group = format_group,
  pattern = "*.templ",
  desc = "Format templ files",
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    if file == "" then
      return
    end

    local result = vim.system({ "templ", "fmt", file }, { text = true }):wait()
    if result.code ~= 0 then
      vim.notify(result.stderr or "templ fmt failed", vim.log.levels.ERROR)
      return
    end

    vim.cmd("checktime " .. args.buf)
  end,
})
