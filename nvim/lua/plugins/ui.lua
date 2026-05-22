return {
  -- ── UI plugins ─────────────────────────────────────────────────────────────
  {
    "folke/noice.nvim",
    opts = {
      cmdline = { view = "cmdline" },
    },
  },

  { "folke/zen-mode.nvim", enabled = true },

  -- ── Colorscheme ────────────────────────────────────────────────────────────
  {
    "projekt0n/github-nvim-theme",
    dependencies = {
      "nvim-lualine/lualine.nvim",
      "akinsho/bufferline.nvim",
      "SmiteshP/nvim-navic",
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

          palettes = {
            all = {
              bg1 = t.bg,
            },
          },

          groups = {
            all = {
              Normal = { bg = t.bg, fg = t.fg },
              NormalFloat = { bg = t.bg },
              LineNr = { fg = t.muted },

              StatusLine = { bg = t.bg, fg = t.fg },
              StatusLineNC = { bg = t.bg, fg = t.muted },

              WinBar = { bg = t.bg, fg = t.fg },
              WinBarNC = { bg = t.bg, fg = t.muted },

              NavicText = { fg = t.fg, bg = t.bg },
              NavicSeparator = { fg = t.muted, bg = t.bg },
              NavicIconsFile = { fg = t.fg, bg = t.bg },
              NavicIconsModule = { fg = t.fg, bg = t.bg },
              NavicIconsNamespace = { fg = t.fg, bg = t.bg },
              NavicIconsPackage = { fg = t.fg, bg = t.bg },
              NavicIconsClass = { fg = t.fg, bg = t.bg },
              NavicIconsMethod = { fg = t.fg, bg = t.bg },
              NavicIconsProperty = { fg = t.fg, bg = t.bg },
              NavicIconsField = { fg = t.fg, bg = t.bg },
              NavicIconsConstructor = { fg = t.fg, bg = t.bg },
              NavicIconsEnum = { fg = t.fg, bg = t.bg },
              NavicIconsInterface = { fg = t.fg, bg = t.bg },
              NavicIconsFunction = { fg = t.fg, bg = t.bg },
              NavicIconsVariable = { fg = t.fg, bg = t.bg },
              NavicIconsConstant = { fg = t.fg, bg = t.bg },
              NavicIconsString = { fg = t.fg, bg = t.bg },
              NavicIconsNumber = { fg = t.fg, bg = t.bg },
              NavicIconsBoolean = { fg = t.fg, bg = t.bg },
              NavicIconsArray = { fg = t.fg, bg = t.bg },
              NavicIconsObject = { fg = t.fg, bg = t.bg },
              NavicIconsKey = { fg = t.fg, bg = t.bg },
              NavicIconsNull = { fg = t.fg, bg = t.bg },
              NavicIconsEnumMember = { fg = t.fg, bg = t.bg },
              NavicIconsStruct = { fg = t.fg, bg = t.bg },
              NavicIconsEvent = { fg = t.fg, bg = t.bg },
              NavicIconsOperator = { fg = t.fg, bg = t.bg },
              NavicIconsTypeParameter = { fg = t.fg, bg = t.bg },
            },
          },
        })

        vim.cmd("colorscheme " .. t.colorscheme)

        for i, color in ipairs(t.terminal) do
          vim.g["terminal_color_" .. (i - 1)] = color
        end

        -- ── Bufferline ──────────────────────────────────────────────────────
        local ok_bufferline, bufferline = pcall(require, "bufferline")

        if ok_bufferline then
          bufferline.setup({
            options = {
              close_command = function(n)
                Snacks.bufdelete(n)
              end,

              right_mouse_command = function(n)
                Snacks.bufdelete(n)
              end,

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

              get_element_icon = function(opts)
                return LazyVim.config.icons.ft[opts.filetype]
              end,
            },
          })
        end

        -- ── Navic attach ────────────────────────────────────────────────────
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local ok_navic, navic = pcall(require, "nvim-navic")

            if not ok_navic then
              return
            end

            local client = vim.lsp.get_client_by_id(args.data.client_id)

            if client and client.server_capabilities.documentSymbolProvider then
              navic.attach(client, args.buf)
            end
          end,
        })

        -- ── Lualine ─────────────────────────────────────────────────────────
        local ok_navic, navic = pcall(require, "nvim-navic")

        require("lualine").setup({
          options = {
            icons_enabled = true,

            component_separators = {
              left = "",
              right = "",
            },

            section_separators = {
              left = "",
              right = "",
            },

            globalstatus = true,

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

          sections = {
            lualine_a = { "mode" },

            lualine_b = {
              "branch",
              "diff",
              "diagnostics",
            },

            lualine_c = {
              {
                "filename",
                path = 1,
              },

              {
                function()
                  if ok_navic and navic.is_available() then
                    return navic.get_location()
                  end

                  return ""
                end,

                cond = function()
                  return ok_navic and navic.is_available()
                end,

                color = function()
                  return {
                    fg = t.fg,
                    bg = t.bg,
                  }
                end,
              },
            },

            lualine_x = {
              "encoding",
              "fileformat",
              "filetype",
            },

            lualine_y = {
              "progress",
            },

            lualine_z = {
              "location",
            },
          },

          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
          },
        })
      end

      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",

        callback = function()
          apply(vim.v.option_new == "dark" and "dark" or "light")
        end,
      })

      local cached_mode

      local function detect_mode()
        if cached_mode then
          return cached_mode
        end

        if vim.env.TMUX then
          local result = vim
            .system({ "tmux", "show", "-gqv", "@background" }, { text = true })
            :wait()

          local mode = vim.trim(result.stdout or "")

          if mode == "light" or mode == "dark" then
            cached_mode = mode
            return mode
          end
        end

        cached_mode = vim.o.background == "light" and "light" or "dark"
        return cached_mode
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,

        callback = function()
          apply(detect_mode())
        end,
      })
    end,
  },
}
