-- Automatically install packer
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd('packadd packer.nvim')
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- Reload Neovim whenever you save this file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

local packer = require('packer')

-- Force HTTPS to avoid SSH prompts during headless installs
packer.init({
    git = {
        default_url_format = 'https://github.com/%s'
    }
})

return packer.startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer can manage itself
    -- Dependencies
    use 'nvim-lua/plenary.nvim'

    -- Harpoon (file marking and quick navigation)
    use 'ThePrimeagen/harpoon'

    -- LSP and tooling
    use 'neovim/nvim-lspconfig'
    use { 'williamboman/mason.nvim', run = function() pcall(vim.cmd, 'MasonUpdate') end }
    use 'williamboman/mason-lspconfig.nvim'

    -- Linting (simple, external executables)
    use 'mfussenegger/nvim-lint'

    -- Colorscheme
    use({
        'rose-pine/neovim',
        as = 'rose-pine'
    })

    if packer_bootstrap then
        require('packer').sync()
    end
end)


