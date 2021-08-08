local loop = vim.loop

local M = {}

M.metadata_table = {}

local function on_error(err, data)
    if err then print('ERROR: ' .. err) end
    if data then print("Spotify is not runnning.") end
end

local function on_stdout(err, data)
    if err then print('ERROR: ' .. err) end
    if data then
        for s in data:gmatch("[^\n]+") do
            local key, value = s:match("^(.*):%s(.*)$")
            M.metadata_table[key:match("^.*:(.*)")] = value
        end
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

local function open_uri_handler(uri)
    local stderr = loop.new_pipe(false)

    _uri = loop.spawn("qdbus", {
        args = {
            "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player.OpenUri", uri
        },
        stdio = {nil, nil, stderr}
    }, function()
        stderr:read_stop()
        stderr:close()
        _uri:close()
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

local function parse_uri(spotify_url)
    if not spotify_url:find("/") then
        return spotify_url
    else
        local uri = "spotify:" ..
                        spotify_url:match("^https://open.spotify.com/(.*)?.*$")
                            :gsub("/", ":")
        return uri
    end
end

function M.toggle() vim.schedule(toggle_handler) end

function M.play() vim.schedule(play_handler) end

function M.pause() vim.schedule(pause_handler) end

function M.stop() vim.schedule(stop_handler) end

function M.next() vim.schedule(next_handler) end

function M.prev() vim.schedule(prev_handler) end

function M.metad() vim.schedule(metadata_handler) end

function M.open_uri()
    local uri = vim.fn.input("Enter URI: ", "")
    if #uri > 0 then
        uri = parse_uri(uri)
        vim.schedule(function() open_uri_handler(uri) end)
    end
end

return M
