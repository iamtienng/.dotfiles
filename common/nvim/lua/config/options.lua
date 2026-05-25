-- Options are automatically loaded before lazy.nvim startup.
vim.g.have_nerd_font = true
vim.g.lazyvim_picker = "snacks"

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.autoindent = true
opt.smartindent = true
opt.breakindent = true

opt.scrolloff = 10
opt.sidescrolloff = 8
opt.textwidth = 100
opt.colorcolumn = "+1"
opt.wrap = true
opt.linebreak = true

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

opt.termguicolors = true
opt.clipboard = "unnamedplus"

opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true

opt.mouse = "a"
opt.updatetime = 250
opt.timeoutlen = 300
opt.showmode = false
opt.inccommand = "split"

if vim.fn.has("nvim-0.11") == 1 then
  opt.winborder = "rounded"
end

opt.cmdheight = 1
