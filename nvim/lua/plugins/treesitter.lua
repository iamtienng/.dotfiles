return {
  {
    -- - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    -- - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        -- Essentials
        "bash",
        "vim",
        "json",
        "yaml",
        "lua",
        "query",
        "sql",
        -- Editor
        "comment",
        "markdown",
        "markdown_inline",
        -- Langs
        "c",
        "python",
        "regex",
        "rust",
        "dockerfile",
        "terraform",
        "hcl",
        -- Web bros
        "gotmpl",
        "html",
        "tsx",
        "typescript",
        "javascript",
      },
      ignore_install = { "tex", "latex" },
      -- Autoinstall languages that are not installed
      sync_install = false,
      auto_install = true,
      indent = {
        enable = true,
      },
      highlight = {
        enable = true,
        use_languagetree = true,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        format = {
          cmdline = { lang = "" },
          search_down = { lang = "" },
          search_up = { lang = "" },
          filter = { lang = "" },
          lua = { lang = "" },
        },
      },
    },
  },
}
