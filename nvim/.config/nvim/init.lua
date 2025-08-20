--
-- THIS IS GOOD DON'T TOUCH
--

-- set leader
vim.g.mapleader = " "

-- Basic configs
vim.o.number = true
vim.o.relativenumber = true

vim.o.expandtab = true
vim.o.shiftwidth = 8
vim.o.tabstop = 8
vim.o.termguicolors = true
vim.o.scrolloff=8

vim.opt.guifont = "Hack Nerd Font:h12"

vim.cmd('syntax on')
vim.o.clipboard = 'unnamedplus'

-- Rose Pine theme configuration
require('rose-pine').setup({
    disable_background = true,  -- makes it transparent
    disable_float_background = true,
    dim_inactive_windows = false,
    styles = {
        italic = false,
        transparency = true,
    },
})

vim.cmd('colorscheme rose-pine')

vim.api.nvim_set_keymap('n', '<leader>', ':Explore<CR>',  { noremap = true, silent = true })
-- Completion popup behavior and Ctrl+Space mapping (omnifunc)
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.keymap.set('i', '<C-Space>', '<C-x><C-o>')
vim.keymap.set('i', '<C-@>', '<C-x><C-o>') -- some terminals send Ctrl+@

--
-- LSP
--

vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Diagnostics: show line' })
vim.keymap.set('n', '<leader>q', function() vim.diagnostic.setqflist(); vim.cmd('copen') end, { desc = 'Diagnostics: quickfix' })



--
-- PACKERRR!!!
--

require('plugins')

--
-- Harpoon keymaps
--
local harpoon_ok, harpoon = pcall(require, 'harpoon')
if harpoon_ok then
    local mark = require('harpoon.mark')
    local ui = require('harpoon.ui')

    -- Open Harpoon menu: <leader>pv
    vim.keymap.set('n', '<leader>pv', ui.toggle_quick_menu, { desc = 'Harpoon: Toggle menu' })

    -- Buffer navigation: <leader>h/j/k/l -> 1/2/3/4
    vim.keymap.set('n', '<leader>h', function() ui.nav_file(1) end, { desc = 'Harpoon: Go to file 1' })
    vim.keymap.set('n', '<leader>j', function() ui.nav_file(2) end, { desc = 'Harpoon: Go to file 2' })
    vim.keymap.set('n', '<leader>k', function() ui.nav_file(3) end, { desc = 'Harpoon: Go to file 3' })
    vim.keymap.set('n', '<leader>l', function() ui.nav_file(4) end, { desc = 'Harpoon: Go to file 4' })

    -- Add file to Harpoon: Ctrl+Space in normal mode
    vim.keymap.set('n', '<C-Space>', mark.add_file, { desc = 'Harpoon: Add file' })
else
    vim.schedule(function()
        vim.notify('Harpoon not available yet (installing?). Keymaps will activate once installed.', vim.log.levels.INFO)
    end)
end

--
-- Modular config
--
pcall(require, 'config.lsp')
pcall(require, 'config.lint')

