-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local ignored_clients = {
  yamlls = true,
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local ok_navic, navic = pcall(require, "nvim-navic")
    if not ok_navic or navic.is_available(args.buf) then
      return
    end

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or ignored_clients[client.name] then
      return
    end

    if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, args.buf)
    end
  end,
})

local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require("go.format").goimports() -- goimports + gofmt
  end,
  group = format_sync_grp,
})

-- Custom format for Templ
local custom_format = function()
  if vim.bo.filetype == "templ" then
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local cmd = "templ fmt " .. vim.fn.shellescape(filename)

    vim.fn.jobstart(cmd, {
      on_exit = function()
        -- Reload the buffer only if it's still the current buffer
        if vim.api.nvim_get_current_buf() == bufnr then
          vim.cmd("e!")
        end
      end,
    })
  else
    vim.lsp.buf.format()
  end
end

vim.api.nvim_create_autocmd(
  "BufWritePre",
  { pattern = { "*.templ" }, callback = custom_format, group = format_sync_grp }
)

vim.filetype.add({
  extension = {
    templ = "templ",
    jinja = "jinja",
    jinja2 = "jinja",
    j2 = "jinja",
  },
})

vim.filetype.add({
  pattern = {
    ["%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
  },
})

-- vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#ffffff", bg = "#1e1e1e" }) -- Customize border color
