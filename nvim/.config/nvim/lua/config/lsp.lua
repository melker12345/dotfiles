local has_mason, mason = pcall(require, 'mason')
local has_mason_lsp, mason_lspconfig = pcall(require, 'mason-lspconfig')
local has_lspconfig, lspconfig = pcall(require, 'lspconfig')

if not (has_mason and has_mason_lsp and has_lspconfig) then
    return
end

mason.setup()
mason_lspconfig.setup({
    ensure_installed = {
        'lua_ls',
        'tsserver',
        'basedpyright',
        'ruff_lsp',
        'gopls',
        'rust_analyzer',
    },
    automatic_installation = true,
})

-- Basic LSP keymaps
local on_attach = function(_, bufnr)
    local nmap = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
    end
    -- enable LSP-powered omnifunc for Ctrl+Space
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    nmap('gd', vim.lsp.buf.definition, 'LSP: Go to definition')
    nmap('gr', vim.lsp.buf.references, 'LSP: References')
    nmap('K', vim.lsp.buf.hover, 'LSP: Hover')
    nmap('<leader>rn', vim.lsp.buf.rename, 'LSP: Rename symbol')
    nmap('<leader>ca', vim.lsp.buf.code_action, 'LSP: Code action')
    nmap('[d', vim.diagnostic.goto_prev, 'Diagnostics: Prev')
    nmap(']d', vim.diagnostic.goto_next, 'Diagnostics: Next')
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

mason_lspconfig.setup_handlers({
    function(server)
        lspconfig[server].setup({
            on_attach = on_attach,
            capabilities = capabilities,
        })
    end,
    -- Lua: make the editor config aware of Neovim globals
    ['lua_ls'] = function()
        lspconfig.lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = { globals = { 'vim' } },
                    workspace = { checkThirdParty = false },
                },
            },
        })
    end,
    -- Python: use basedpyright for types; ruff_lsp for linting
    ['basedpyright'] = function()
        lspconfig.basedpyright.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                basedpyright = {
                    analysis = {
                        diagnosticMode = 'workspace',
                        typeCheckingMode = 'basic',
                    },
                },
            },
        })
    end,
    ['ruff_lsp'] = function()
        lspconfig.ruff_lsp.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            init_options = {
                settings = {
                    args = {},
                },
            },
        })
    end,
})


