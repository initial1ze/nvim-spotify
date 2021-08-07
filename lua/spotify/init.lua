local loop = vim.loop

local M = {}

M.is_running = nil
M.metadata_table = {}

local function on_error(err, data)
    if err then print('ERROR: ' .. err) end
    if data then
        print("Spotify is not runnning.")
        --[[ M.is_running = false
    else
        M.is_running = true ]]
    end
end

local function on_stdout(err, data)
    if err then print('ERROR: ' .. err) end
    if data then
        for s in data:gmatch("[^\n]+") do
            local key, value = s:match("^(.*):%s(.*)$")
            M.metadata_table[key:match("^.*:(.*)")] = value
            -- table.insert(M.metadata_table, ok)
        end
        --[[ print('Current track: ' .. M.metadata_table["title"] .. ' - ' ..
                  M.metadata_table["artist"]) ]]
        -- print(vim.inspect(M.metadata_table))
    end
end

local function toggle_handler()
    local stderr = loop.new_pipe(false)

    _toggle = loop.spawn("qdbus", {
        args = {
            "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player.PlayPause"
        },
        stdio = {nil, nil, stderr}
    }, function()
        stderr:read_stop()
        stderr:close()
        _toggle:close()
    end)

    loop.read_start(stderr, on_error)
end

local function play_handler()
    local stderr = loop.new_pipe(false)

    _play = loop.spawn("qdbus", {
        args = {
            "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player.Play"
        },
        stdio = {nil, nil, stderr}
    }, function()
        stderr:read_stop()
        stderr:close()
        _play:close()
    end)

    loop.read_start(stderr, on_error)
end

local function pause_handler()
    local stderr = loop.new_pipe(false)

    _pause = loop.spawn("qdbus", {
        args = {
            "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player.Pause"
        },
        stdio = {nil, nil, stderr}
    }, function()
        stderr:read_stop()
        stderr:close()
        _pause:close()
    end)

    loop.read_start(stderr, on_error)
end

local function stop_handler()
    local stderr = loop.new_pipe(false)

    _stop = loop.spawn("qdbus", {
        args = {
            "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player.Stop"
        },
        stdio = {nil, nil, stderr}
    }, function()
        stderr:read_stop()
        stderr:close()
        _stop:close()
    end)

    loop.read_start(stderr, on_error)
end

local function next_handler()
    local stderr = loop.new_pipe(false)

    _next = loop.spawn("qdbus", {
        args = {
            "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player.Next"
        },
        stdio = {nil, nil, stderr}
    }, function()
        stderr:read_stop()
        stderr:close()
        _next:close()
    end)

    loop.read_start(stderr, on_error)
end

local function prev_handler()
    local stderr = loop.new_pipe(false)

    _prev = loop.spawn("qdbus", {
        args = {
            "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player.Previous"
        },
        stdio = {nil, nil, stderr}
    }, function()
        stderr:read_stop()
        stderr:close()
        _prev:close()
    end)

    loop.read_start(stderr, on_error)
end

local function metadata_handler()
    local stderr = loop.new_pipe(false)
    local stdout = loop.new_pipe(false)

    _meta = loop.spawn("qdbus", {
        args = {
            "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player.Metadata"
        },
        stdio = {nil, stdout, stderr}
    }, function()
        stderr:read_stop()
        stdout:read_stop()
        stderr:close()
        stdout:close()
        _meta:close()
    end)

    loop.read_start(stderr, on_error)
    loop.read_start(stdout, on_stdout)
end

local function check()
    if M.is_running == false then
        vim.cmd "echom \"Spotify is not runnning.\""
    else
        -- print(M.metadata_table["title"])
        -- print(M.metadata_table["title"] .. ' - ' .. M.metadata_table["artist"])
    end
end

function M.toggle()
    vim.schedule(toggle_handler)
    -- check()
    -- vim.schedule(metadata_handler)
end
function M.play()
    vim.schedule(play_handler)
    -- vim.schedule(metadata_handler)
    -- check()
end
function M.pause()
    vim.schedule(pause_handler)
    -- check()
end
function M.stop()
    vim.schedule(stop_handler)
    -- check()
end
function M.next()
    vim.schedule(next_handler)
    -- vim.schedule(metadata_handler)
    -- check()
end
function M.prev()
    vim.schedule(prev_handler)
    -- vim.schedule(metadata_handler)
    -- check()
end
function M.metad()
    vim.schedule(metadata_handler)
    -- vim.schedule(metadata_handler)
    -- check()
end

return M
