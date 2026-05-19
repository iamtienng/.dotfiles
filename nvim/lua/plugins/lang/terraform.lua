return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {
          filetypes = { "terraform", "hcl" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "tflint" } },
  },
}
