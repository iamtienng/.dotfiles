return {
  { -- NOTE: nvim-lspconfig already init with LazyVim by default, so this is the extra configs
    -- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig
    "neovim/nvim-lspconfig",
    dependencies = {
      { -- status update for LSP
        "j-hui/fidget.nvim",
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },
}
