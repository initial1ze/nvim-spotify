local loop = vim.loop
local api = vim.api

local Spotify = {}

Spotify.spotify_running = false
Spotify.spotify_id = nil
local wm_results = {}
local wm_ids = {}
local results = {}

function Spotify:refresh()

    --[[ vim.schedule(Spotify.wmctrl_fetch)
    vim.schedule(Spotify.pgrep) ]]
    if not wm_handle then vim.schedule(Spotify.wmctrl_fetch) end
    if not handle then vim.schedule(Spotify.pgrep) end
    -- print(Spotify.spotify_id, Spotify.spotify_running)
end

function Spotify:check()
    if Spotify.spotify_running and Spotify.spotify_id then
        return true
    else
        return false
    end
end

function Spotify:pgrep()

    local function okay()
        for _, pid in pairs(results) do
            if wm_ids[pid] then
                Spotify.spotify_running = true
                Spotify.spotify_id = pid
            end
        end
    end

    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)

    handle = loop.spawn("pgrep",
                        {args = {"spotify"}, stdio = {nil, stdout, stderr}},
                        function()
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
        -- handle:close()
        okay()
    end)

    local function on_read(err, data)
        if err then print(err) end
        if data then
            for s in data:gmatch("[^\n]+") do
                table.insert(results, s)
            end
        end
    end

    loop.read_start(stdout, on_read)
    loop.read_stop(stderr, on_read)

end

function Spotify:wmctrl_fetch()
    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    wm_handle = loop.spawn("wmctrl", {
        args = {"-l", "-p"},
        stdio = {nil, stdout, stderr}
    }, function()
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
        -- wm_handle:close()
    end)

    local function on_wm_read(err, data)
        if err then print(err) end
        if data then
            for s in data:gmatch("[^\n]+") do
                table.insert(wm_results, s)
            end
            for _, val in pairs(wm_results) do
                local win_id, process_id = val:match("^(.+)%s+%d+%s+(%d+).*$")
                wm_ids[process_id] = win_id:match("[^%s]+")
            end
        end
    end

    loop.read_start(stdout, on_wm_read)
    loop.read_stop(stderr, on_wm_read)
end

function Spotify:_wmctrl_switch()
    Spotify:refresh()

    if not Spotify:check() then
        print("Spotify is not running.")
        return
    end
    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    if Spotify.spotify_running and Spotify.spotify_id then
        sm_handle = loop.spawn("wmctrl", {
            args = {"-i", "-a", wm_ids[Spotify.spotify_id]},
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            sm_handle:close()
        end)

        local function on_wm_read(err, data)
            if err then print(err) end
            if data then
                for s in data:gmatch("[^\n]+") do
                    table.insert(wm_results, s)
                end
                for _, val in pairs(wm_results) do
                    local win_id, process_id = val:match(
                                                   "^(.+)%s+%d+%s+(%d+).*$")
                    wm_ids[process_id] = win_id:match("[^%s]+")
                end
            end
        end

        loop.read_start(stdout, on_wm_read)
        loop.read_stop(stderr, on_wm_read)
    end
end

function Spotify:focus() vim.schedule(Spotify._wmctrl_switch) end

function Spotify:_toggle_handler()
    Spotify:refresh()

    if not Spotify:check() then
        print("Spotify is not running.")
        return
    end
    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    if Spotify.spotify_running and Spotify.spotify_id then
        toggle = loop.spawn("qdbus", {
            args = {
                "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
                "org.mpris.MediaPlayer2.Player.PlayPause"
            },
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            toggle:close()
        end)
        --[[ toggle = loop.spawn("dbus-send", {
            args = {
                "--print-reply", "--dest=org.mpris.MediaPlayer2.spotify",
                "/org/mpris/MediaPlayer2",
                "org.mpris.MediaPlayer2.Player.PlayPause"
            },
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            toggle:close()
        end) ]]

        local function on_wm_read(err, _) if err then print(err) end end

        loop.read_start(stdout, on_wm_read)
        loop.read_stop(stderr, on_wm_read)
    end
end

function Spotify:_play_handler()
    Spotify:refresh()

    if not Spotify:check() then
        print("Spotify is not running.")
        return
    end
    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    if Spotify.spotify_running and Spotify.spotify_id then
        play = loop.spawn("dbus-send", {
            args = {
                "--print-reply", "--dest=org.mpris.MediaPlayer2.spotify",
                "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player.Play"
            },
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            play:close()
        end)

        local function on_wm_read(err, _) if err then print(err) end end

        loop.read_start(stdout, on_wm_read)
        loop.read_stop(stderr, on_wm_read)
    end
end

function Spotify:_pause_handler()
    Spotify:refresh()

    if not Spotify:check() then
        print("Spotify is not running.")
        return
    end
    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    if Spotify.spotify_running and Spotify.spotify_id then
        pause = loop.spawn("dbus-send", {
            args = {
                "--print-reply", "--dest=org.mpris.MediaPlayer2.spotify",
                "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player.Pause"
            },
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            pause:close()
        end)

        local function on_wm_read(err, _) if err then print(err) end end

        loop.read_start(stdout, on_wm_read)
        loop.read_stop(stderr, on_wm_read)
    end
end

function Spotify:_next_handler()
    Spotify:refresh()

    if not Spotify:check() then
        print("Spotify is not running.")
        return
    end

    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    if Spotify.spotify_running and Spotify.spotify_id then
        next_handle = loop.spawn("dbus-send", {
            args = {
                "--print-reply", "--dest=org.mpris.MediaPlayer2.spotify",
                "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player.Next"
            },
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            next_handle:close()
        end)

        local function on_wm_read(err, _) if err then print(err) end end

        loop.read_start(stdout, on_wm_read)
        loop.read_stop(stderr, on_wm_read)
    end
end

function Spotify:_prev_handler()

    Spotify:refresh()

    if not Spotify:check() then
        print("Spotify is not running.")
        return
    end
    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    if Spotify.spotify_running and Spotify.spotify_id then
        prev = loop.spawn("dbus-send", {
            args = {
                "--print-reply", "--dest=org.mpris.MediaPlayer2.spotify",
                "/org/mpris/MediaPlayer2",
                "org.mpris.MediaPlayer2.Player.Previous"
            },
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            prev:close()
        end)

        local function on_wm_read(err, _) if err then print(err) end end

        loop.read_start(stdout, on_wm_read)
        loop.read_stop(stderr, on_wm_read)
    end
end

function Spotify:_stop_handler()
    Spotify:refresh()

    if not Spotify:check() then
        print("Spotify is not running.")
        return
    end
    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    if Spotify.spotify_running and Spotify.spotify_id then
        stop = loop.spawn("dbus-send", {
            args = {
                "--print-reply", "--dest=org.mpris.MediaPlayer2.spotify",
                "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player.Stop"
            },
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            stop:close()
        end)

        local function on_wm_read(err, _) if err then print(err) end end

        loop.read_start(stdout, on_wm_read)
        loop.read_stop(stderr, on_wm_read)
    end
end

local spotify_meta = {}

function Spotify:metadata()
    -- dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep -Ev "^method" |  grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)'
    -- qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Metadata
    Spotify:refresh()
    local stdout = loop.new_pipe(false)
    local stderr = loop.new_pipe(false)
    if Spotify.spotify_running and Spotify.spotify_id then
        metadata = loop.spawn("qdbus", {
            args = {
                "org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2",
                "org.mpris.MediaPlayer2.Player.Metadata"
                -- "string:\'org.mpris.MediaPlayer2.Player\'",
                -- "string:\'Metadata\'"
            },
            stdio = {nil, stdout, stderr}
        }, function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            metadata:close()
        end)

        local function on_wm_read(err, data)
            if err then print(err) end
            if data then
                print(data)
                table.insert(spotify_meta, data)
            end
        end

        loop.read_start(stdout, on_wm_read)
        loop.read_stop(stderr, on_wm_read)
    end
end

function Spotify:toggle() vim.schedule(Spotify._toggle_handler) end
function Spotify:play() vim.schedule(Spotify._play_handler) end
function Spotify:pause() vim.schedule(Spotify._pause_handler) end
function Spotify:next() vim.schedule(Spotify._next_handler) end
function Spotify:prev() vim.schedule(Spotify._prev_handler) end
function Spotify:stop() vim.schedule(Spotify._stop_handler) end

return Spotify
