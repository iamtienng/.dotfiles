return {
  -- ── UI plugins ─────────────────────────────────────────────────────────────
  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        cmdline = { view = "cmdline" },
        color = { fg = "#ff9e64" },
      })
    end,
  },
  { "folke/zen-mode.nvim", enabled = true },

  -- ── Colorscheme ────────────────────────────────────────────────────────────
  {
    "projekt0n/github-nvim-theme",
    dependencies = {
      "nvim-lualine/lualine.nvim",
      "akinsho/bufferline.nvim",
    },
    config = function()
      local themes = {
        dark = {
          bg = "#101216",
          fg = "#ffffff",
          muted = "#444c56",
          colorscheme = "github_dark_colorblind",
          terminal = {
            "#101216",
            "#f47067",
            "#57ab5a",
            "#c69026",
            "#539bf5",
            "#b083f0",
            "#39c5cf",
            "#cdd9e5",
            "#444c56",
            "#ff938a",
            "#6bc46d",
            "#daaa3f",
            "#6cb6ff",
            "#dcbdfb",
            "#56d4dd",
            "#ffffff",
          },
        },
        light = {
          bg = "#f4f4f4",
          fg = "#000000",
          muted = "#999999",
          colorscheme = "github_light_colorblind",
          terminal = {
            "#f4f4f4",
            "#cf2218",
            "#116329",
            "#4d2d00",
            "#0969da",
            "#8250df",
            "#1b7c83",
            "#24292f",
            "#999999",
            "#a40e26",
            "#1a7f37",
            "#633c01",
            "#218bff",
            "#a475f9",
            "#3192aa",
            "#000000",
          },
        },
      }

      local function apply(mode)
        local t = themes[mode]

        vim.cmd("highlight clear")
        vim.cmd("syntax reset")
        vim.opt.background = mode

        require("github-theme").setup({
          options = {
            transparent = false,
            hide_end_of_buffer = true,
            terminal_colors = false,
          },
          palettes = { all = { bg1 = t.bg } },
          groups = {
            all = {
              Normal = { bg = t.bg, fg = t.fg },
              NormalFloat = { bg = t.bg },
              LineNr = { fg = t.muted },
            },
          },
        })

        vim.cmd("colorscheme " .. t.colorscheme)

        for i, color in ipairs(t.terminal) do
          vim.g["terminal_color_" .. (i - 1)] = color
        end

        local ok_bufferline, bufferline = pcall(require, "bufferline")
        if ok_bufferline then
          bufferline.setup({
            options = {
              -- stylua: ignore
              close_command = function(n)Snacks.bufdelete(n) end,
              -- stylua: ignore
              right_mouse_command = function(n) Snacks.bufdelete(n) end,
              diagnostics = "nvim_lsp",
              always_show_bufferline = false,
              diagnostics_indicator = function(_, _, diag)
                local icons = LazyVim.config.icons.diagnostics
                local ret = (diag.error and icons.Error .. diag.error .. " " or "")
                  .. (diag.warning and icons.Warn .. diag.warning or "")
                return vim.trim(ret)
              end,
              offsets = {
                {
                  filetype = "neo-tree",
                  text = "Neo-tree",
                  highlight = "Directory",
                  text_align = "left",
                },
                {
                  filetype = "snacks_layout_box",
                },
              },
              ---@param opts bufferline.IconFetcherOpts
              get_element_icon = function(opts)
                return LazyVim.config.icons.ft[opts.filetype]
              end,
            },
          })
        end

        require("lualine").setup({
          options = {
            icons_enabled = true,
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            theme = {
              normal = {
                a = { fg = t.fg, bg = t.bg, gui = "bold" },
                b = { fg = t.fg, bg = t.bg },
                c = { fg = t.fg, bg = t.bg },
              },
              inactive = {
                a = { fg = t.muted, bg = t.bg },
                b = { fg = t.muted, bg = t.bg },
                c = { fg = t.muted, bg = t.bg },
              },
            },
          },
        })
      end

      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = function()
          apply(vim.v.option_new == "dark" and "dark" or "light")
        end,
      })

      apply(vim.o.background == "dark" and "dark" or "light")
    end,
  },
}
