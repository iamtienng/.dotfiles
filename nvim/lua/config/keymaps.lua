-- Keymaps are automatically loaded on the VeryLazy event.
vim.g.mapleader = " "

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("v", "J", ":m '>+1<CR>gv=gv", vim.tbl_extend("force", opts, { desc = "Move selection down" }))
map("v", "K", ":m '<-2<CR>gv=gv", vim.tbl_extend("force", opts, { desc = "Move selection up" }))

map(
  "n",
  "<Esc>",
  "<cmd>nohlsearch<CR>",
  vim.tbl_extend("force", opts, { desc = "Clear search highlight" })
)

for key, direction in pairs({
  ["<Left>"] = "h",
  ["<Right>"] = "l",
  ["<Up>"] = "k",
  ["<Down>"] = "j",
}) do
  map("n", key, function()
    vim.notify("Use " .. direction .. " to move", vim.log.levels.WARN, { title = "Vim motion" })
  end, { desc = "Disable arrow key" })
end
