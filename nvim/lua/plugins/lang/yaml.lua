return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              completion = true,
              hover = true,
              validate = true,
              schemaStore = { enable = true },
              schemas = {
                kubernetes = { "*.k8s.yaml", "*.k8s.yml", "k8s/**/*.yaml", "k8s/**/*.yml" },
              },
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
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, { "gitlab-ci-ls" })
    end,
  },
}
