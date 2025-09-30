-- This is the init.lua

local tracker = require("codetime.tracker")
local stats = require("codetime.stats")
local storage = require("codetime.storage")

local M = {}

function M.setup()
    vim.api.nvim_create_augroup("CodeTime", { clear = true })

    vim.api.nvim_create_autocmd({ "FocusGained", "CursorMoved", "InsertEnter", "BufWritePost" }, {
        group = "CodeTime",
        pattern = "*",
        callback = function()
            tracker.start()
        end,
    })

    vim.api.nvim_create_autocmd({ "FocusLost", "CursorHold"}, {
         group = "CodeTime",
        pattern = "*",
        callback = function()
            tracker.stop()
        end,
    })
    
    -- Save on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = "CodeTime",
        callback = function()
            tracker.stop()
        end,
    })

    -- Create user commands
    vim.api.nvim_create_user_command("CodeTime", function()
        stats.show_stats()
    end, { desc = "Show CodeTime statistics" })
    
    vim.api.nvim_create_user_command("CodeTimeGoal", function(opts)
        local minutes = tonumber(opts.args)
        if minutes and minutes > 0 then
            storage.set_daily_goal(minutes)
            vim.notify("Daily goal set to " .. storage.format_time(minutes), vim.log.levels.INFO)
        else
            vim.notify("Usage: :CodeTimeGoal <minutes>  (e.g., :CodeTimeGoal 60 for 1 hour)", vim.log.levels.ERROR)
        end
    end, { nargs = 1, desc = "Set daily coding goal in minutes" })
end

-- Export stats module for statusline integration
M.stats = stats
M.storage = storage
M.tracker = tracker

return M

