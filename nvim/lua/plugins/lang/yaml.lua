return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              schemas = { kubernetes = "globPattern" },
              completion = true,
              hover = true,
            },
            diagnosticsLimit = 50,
            showDiagnosticsDirectly = false,
          },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "gitlab-ci-ls",
      },
    },
  },
}
