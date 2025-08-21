local has_lint, lint = pcall(require, 'lint')
if not has_lint then return end

-- Configure linters per filetype
lint.linters_by_ft = {
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    javascriptreact = { 'eslint_d' },
    typescriptreact = { 'eslint_d' },
    go = { 'golangcilint' },
    json = { 'jsonlint' },
    html = { 'htmlhint' },
    css = { 'stylelint' },
}

-- Run lint on save
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    callback = function()
        lint.try_lint()
    end,
})


