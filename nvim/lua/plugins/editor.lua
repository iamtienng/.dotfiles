return {
  { "mg979/vim-visual-multi", event = "BufReadPost" },

  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
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

  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    opts = {
      highlight = false,
      separator = "  ",
      depth_limit = 5,
    },
    config = function(_, opts)
      local navic = require("nvim-navic")
      navic.setup(opts)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-navic-attach", { clear = true }),
        desc = "Attach nvim-navic once per buffer",
        callback = function(args)
          if navic.is_available(args.buf) then
            return
          end

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, args.buf)
          end
        end,
      })
    end,
  },

  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
  },

  {
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
          never_show = { ".git", ".DS_Store", "thumbs.db" },
        },
        follow_current_file = { enabled = true },
        group_empty_dirs = true,
        use_libuv_file_watcher = true,
      },
    },
  },
}
