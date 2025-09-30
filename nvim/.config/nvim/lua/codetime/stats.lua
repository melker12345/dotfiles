-- Statistics display

local storage = require('codetime.storage')

local M = {}

-- Sort table by values in descending order
local function sort_by_value(tbl)
    local sorted = {}
    for key, value in pairs(tbl) do
        table.insert(sorted, {key = key, value = value})
    end
    table.sort(sorted, function(a, b) return a.value > b.value end)
    return sorted
end

-- Get ISO week number
local function get_week_number(timestamp)
    return tonumber(os.date("%V", timestamp))
end

-- Generate weekly activity grid (4 weeks, 7 days each)
local function generate_activity_grid(by_date, goal_minutes)
    local lines = {}
    local today = os.time()
    
    table.insert(lines, "ACTIVITY (last 4 weeks)")
    table.insert(lines, "")
    table.insert(lines, "      M  T  W  T  F  S  S")
    
    -- Display 4 weeks (28 days)
    for week = 3, 0, -1 do
        local week_start = today - (week * 7 * 86400)
        local week_num = get_week_number(week_start)
        
        local week_line = string.format(" W%02d  ", week_num)
        
        -- 7 days in a week
        for day = 0, 6 do
            local timestamp = week_start + (day * 86400)
            local date = os.date("%Y-%m-%d", timestamp)
            local minutes = (by_date and by_date[date]) or 0
            
            -- Simple: either goal met or not
            local symbol = (minutes >= goal_minutes) and "■" or "□"
            week_line = week_line .. symbol .. "  "
        end
        
        table.insert(lines, week_line)
    end
    
    table.insert(lines, "")
    table.insert(lines, "Legend: □ not met  ■ goal met")
    
    return lines
end

-- Center text in a given width
local function center_text(text, width)
    local text_len = vim.fn.strdisplaywidth(text)
    if text_len >= width then
        return text
    end
    local padding = math.floor((width - text_len) / 2)
    return string.rep(" ", padding) .. text
end

-- Display comprehensive stats
function M.show_stats()
    local data = storage.load()
    local lines = {}
    
    -- Check if we should refresh the grid (every 4 weeks)
    if storage.should_refresh_grid() then
        storage.mark_grid_refreshed()
    end
    
    local window_width = 58
    
    -- Header
    table.insert(lines, "")
    table.insert(lines, center_text("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", window_width))
    table.insert(lines, center_text("⏱  C O D E T I M E   S T A T S", window_width))
    table.insert(lines, center_text("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", window_width))
    table.insert(lines, "")
    
    -- Overall stats
    local total_time_str = storage.format_time(data.total_minutes or 0)
    table.insert(lines, "  📊 OVERALL")
    table.insert(lines, "     Total coding time: " .. total_time_str)
    table.insert(lines, "")
    
    -- Today's stats and goal
    local today_mins = storage.get_today()
    local goal_mins = storage.get_daily_goal()
    local goal_met = storage.is_goal_met_today()
    local progress_pct = math.floor((today_mins / goal_mins) * 100)
    
    table.insert(lines, "  📅 TODAY")
    table.insert(lines, "     Time coded: " .. storage.format_time(today_mins))
    table.insert(lines, "     Daily goal: " .. storage.format_time(goal_mins))
    table.insert(lines, "     Progress:   " .. progress_pct .. "%" .. (goal_met and " ✓" or ""))
    table.insert(lines, "")
    
    -- Streak
    local streak = storage.get_current_streak()
    local goal_met_days = storage.get_goal_met_days()
    table.insert(lines, "  🔥 STREAKS")
    table.insert(lines, "     Current streak:     " .. streak .. " day" .. (streak ~= 1 and "s" or ""))
    table.insert(lines, "     Total days at goal: " .. #goal_met_days)
    table.insert(lines, "")
    
    -- GitHub-style activity grid
    table.insert(lines, "  ──────────────────────────────────────────────────")
    table.insert(lines, "")
    local grid_lines = generate_activity_grid(data.by_date, goal_mins)
    for _, line in ipairs(grid_lines) do
        table.insert(lines, "  " .. line)
    end
    table.insert(lines, "")
    table.insert(lines, "  ──────────────────────────────────────────────────")
    
    -- Top languages/filetypes
    if data.by_filetype and next(data.by_filetype) then
        table.insert(lines, "")
        table.insert(lines, "  💻 LANGUAGES")
        local filetypes = sort_by_value(data.by_filetype)
        local count = 0
        local total = data.total_minutes > 0 and data.total_minutes or 1 -- Avoid division by zero
        for _, entry in ipairs(filetypes) do
            if count >= 5 then break end
            local ft_name = entry.key ~= "" and entry.key or "no filetype"
            local percent = math.floor((entry.value / total) * 100)
            -- Pad filetype name to 12 chars for alignment
            local padded_ft = ft_name .. string.rep(" ", math.max(0, 12 - #ft_name))
            table.insert(lines, string.format("     %s %s (%d%%)", padded_ft, storage.format_time(entry.value), percent))
            count = count + 1
        end
    end
    
    table.insert(lines, "")
    table.insert(lines, center_text("Press q or Esc to close", window_width))
    table.insert(lines, "")
    
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    
    -- Fixed window size for consistent layout
    local width = 60
    local height = math.min(#lines, 35) -- Cap at 35 lines
    local win_height = vim.api.nvim_get_option('lines')
    local win_width = vim.api.nvim_get_option('columns')
    
    -- Center the window
    local row = math.max(0, math.floor((win_height - height) / 2) - 1)
    local col = math.max(0, math.floor((win_width - width) / 2))
    
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' CodeTime ',
        title_pos = 'center'
    }
    
    local win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Set window options for better appearance
    vim.api.nvim_win_set_option(win, 'winblend', 0)
    
    -- Set up keybindings to close the window
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', { noremap = true, silent = true })
end

return M
