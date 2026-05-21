return { -- https://www.lazyvim.org/plugins/editor
  { "mg979/vim-visual-multi", event = "BufReadPost" },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    -- will be disabled when mini-diffs is enabled
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
    },
  },
  { -- change trouble config
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
  },
  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    opts = {
      highlight = false,
      separator = "  ",
      depth_limit = 5,
    },
  },
  { -- Highlight todo, notes, etc in comments
    "folke/todo-comments.nvim",
    event = "LazyFile",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<BS>"] = "navigate_up",
          ["."] = "set_root",
          ["H"] = "toggle_hidden",
          ["R"] = "refresh",
          ["i"] = "show_file_details",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["a"] = { "add", config = { show_path = "relative" } },
          ["c"] = { "copy", config = { show_path = "relative" } },
          ["m"] = { "move", config = { show_path = "relative" } },
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            ".git",
            ".DS_Store",
            "thumbs.db",
          },
        },
        follow_current_file = { enabled = true },
        group_empty_dirs = true,
        use_libuv_file_watcher = true,
      },
    },
  },
}
