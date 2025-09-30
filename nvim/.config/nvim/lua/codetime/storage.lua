-- This is for handling storage of stats.

local M = {}

local data_path = vim.fn.stdpath("data") .. "/codetime.json"

-- Get current date in YYYY-MM-DD format
local function get_date()
    return os.date("%Y-%m-%d")
end

-- Initialize empty data structure
local function init_data()
    return {
        total_minutes = 0,
        by_date = {},
        by_filetype = {},
        daily_goal_minutes = 60, -- Default: 60 minutes (1 hour) per day
        last_grid_update = os.date("%Y-%m-%d"), -- Track when we last updated the grid calculation
    }
end

function M.load()
    local file = io.open(data_path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content and content ~= "" then
            local success, data = pcall(vim.fn.json_decode, content)
            if success and data then
                -- Ensure daily_goal_minutes exists
                if not data.daily_goal_minutes then
                    data.daily_goal_minutes = 60
                end
                return data
            end
        end
    end
    return init_data()
end

function M.save(elapsed_seconds, filetype)
    local data = M.load()
    local date = get_date()
    local minutes = math.floor(elapsed_seconds / 60)
    
    -- Only save if at least 1 second elapsed
    if elapsed_seconds < 1 then
        return
    end
    
    -- Update total time (stored in minutes)
    data.total_minutes = (data.total_minutes or 0) + minutes
    
    -- Update by date
    data.by_date = data.by_date or {}
    data.by_date[date] = (data.by_date[date] or 0) + minutes
    
    -- Update by filetype (if provided)
    if filetype and filetype ~= "" then
        data.by_filetype = data.by_filetype or {}
        data.by_filetype[filetype] = (data.by_filetype[filetype] or 0) + minutes
    end
    
    local file = io.open(data_path, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
    end
end

-- Format minutes into human-readable time
function M.format_time(minutes)
    if minutes < 1 then
        return "< 1 min"
    elseif minutes < 60 then
        return string.format("%d min", minutes)
    else
        local hours = math.floor(minutes / 60)
        local mins = minutes % 60
        if mins == 0 then
            return string.format("%dh", hours)
        else
            return string.format("%dh %dm", hours, mins)
        end
    end
end

-- Get today's coding time
function M.get_today()
    local data = M.load()
    local date = get_date()
    return (data.by_date and data.by_date[date]) or 0
end

-- Set daily goal in minutes
function M.set_daily_goal(minutes)
    local data = M.load()
    data.daily_goal_minutes = minutes
    
    local file = io.open(data_path, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
    end
end

-- Get daily goal
function M.get_daily_goal()
    local data = M.load()
    return data.daily_goal_minutes or 60
end

-- Check if today's goal is met
function M.is_goal_met_today()
    local today_minutes = M.get_today()
    local goal = M.get_daily_goal()
    return today_minutes >= goal
end

-- Get days that met the goal (returns sorted array of dates)
function M.get_goal_met_days()
    local data = M.load()
    local goal = data.daily_goal_minutes or 60
    local met_days = {}
    
    if data.by_date then
        for date, minutes in pairs(data.by_date) do
            if minutes >= goal then
                table.insert(met_days, date)
            end
        end
    end
    
    table.sort(met_days)
    return met_days
end

-- Get current streak of consecutive days meeting goal
function M.get_current_streak()
    local data = M.load()
    local goal = data.daily_goal_minutes or 60
    local streak = 0
    local current_date = os.time()
    
    -- Check backwards from today
    for i = 0, 365 do -- Check up to a year back
        local check_date = os.date("%Y-%m-%d", current_date - (i * 86400)) -- 86400 = seconds in a day
        local minutes = (data.by_date and data.by_date[check_date]) or 0
        
        if minutes >= goal then
            streak = streak + 1
        else
            break
        end
    end
    
    return streak
end

-- Check if we need to refresh the grid (every 4 weeks = 28 days)
function M.should_refresh_grid()
    local data = M.load()
    local last_update = data.last_grid_update
    
    if not last_update then
        return true
    end
    
    -- Parse the last update date
    local year, month, day = last_update:match("(%d+)-(%d+)-(%d+)")
    if not year then
        return true
    end
    
    local last_update_time = os.time({year = year, month = month, day = day})
    local current_time = os.time()
    local days_since_update = math.floor((current_time - last_update_time) / 86400)
    
    -- Refresh every 28 days (4 weeks)
    return days_since_update >= 28
end

-- Mark that we've refreshed the grid
function M.mark_grid_refreshed()
    local data = M.load()
    data.last_grid_update = get_date()
    
    local file = io.open(data_path, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
    end
end

return M
