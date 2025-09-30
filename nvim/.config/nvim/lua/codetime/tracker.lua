-- Tracker

local storage = require('codetime.storage')

local M = {}

local start_time = 0
local is_active = false
local session_start = 0
local session_time = 0

function M.start()
    if not is_active then
        start_time = os.time()
        is_active = true
        if session_start == 0 then
            session_start = os.time()
        end
    end
end

function M.stop()
    if is_active then
        local elapsed_time = os.time() - start_time
        local filetype = vim.bo.filetype
        storage.save(elapsed_time, filetype)
        session_time = session_time + elapsed_time
        is_active = false
    end
end

-- Get session time in minutes
function M.get_session_time()
    local current_session = session_time
    if is_active then
        current_session = current_session + (os.time() - start_time)
    end
    return math.floor(current_session / 60)
end

-- Reset session timer (called when starting a new Neovim instance)
function M.reset_session()
    session_start = os.time()
    session_time = 0
end

return M
