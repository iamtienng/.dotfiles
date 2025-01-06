-- Might work, might not work, who knows
-- Freaking Primeagen
return {
  {
    "ThePrimeagen/harpoon",
    name = "harpoon",
    lazy = false,
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({})

      vim.keymap.set("n", "<leader>hm", function()
        harpoon:list():add()
      end, { desc = "[H]arpoon [M]arks" })
      vim.keymap.set("n", "<leader>ha", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Show [H]arpoon [A]ll" })
      vim.keymap.set("n", "<leader>hn", function()
        harpoon:list():next()
      end, { desc = "Go to [H]arpoon [N]ext mark" })
      vim.keymap.set("n", "<leader>hp", function()
        harpoon:list():prev()
      end, { desc = "Go to [H]arpoon [P]revious mark" })
    end,
  },
}
