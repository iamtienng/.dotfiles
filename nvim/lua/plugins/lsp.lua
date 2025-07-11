return {
  { -- NOTE: nvim-lspconfig already init with LazyVim by default, so this is the extra configs
    -- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig
    "neovim/nvim-lspconfig",
    dependencies = {
      { -- status update for LSP
        "j-hui/fidget.nvim",
      },
    },
    opts = {
      servers = {
        terraformls = {
          filetypes = { "terraform", "hcl" },
          on_attach = function(client, bufnr)
            if client.server_capabilities.documentFormattingProvider then
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format({ async = false })
                end,
              })
            end
          end,
        },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
      ensure_installed = { "tflint" },
    },
    { "mason-org/mason-lspconfig.nvim" },
  },
}
