return { -- https://www.lazyvim.org/plugins/ui
{
    "akinsho/bufferline.nvim",
    event = "VeryLazy"
}, {
    require("noice").setup({
    cmdline = {
        view = "cmdline",
    },
    color = { fg = "#ff9e64" },
})}}
