local socket = require("socket")
local config = require("config")
local router = require("router")

local host = config.Host or "0.0.0.0"
local port = config.Port or 8080
local timeout = config.Timeout or 30

local function try_bind(h, p)
    local ok, srv = pcall(function() return socket.bind(h, p) end)
    if ok and srv then return srv end
    return nil
end

local server = try_bind(host, port)
if not server then
    -- fallback to 0.0.0.0 if configured host is invalid
    server = assert(socket.bind("0.0.0.0", port))
    print(string.format("Bound to fallback host 0.0.0.0:%d", port))
else
    print(string.format("Listening on %s:%d", host, port))
end

server:settimeout(0)

local function send_response(client, status_code, status_text, headers, body)
    headers = headers or {}
    body = body or ""
    headers["Content-Length"] = tostring(#body)
    client:send(string.format("HTTP/1.1 %d %s\r\n", status_code, status_text))
    for k, v in pairs(headers) do
        client:send(string.format("%s: %s\r\n", k, v))
    end
    client:send("\r\n")
    if #body > 0 then client:send(body) end
end

local function handle_client(client)
    client:settimeout(timeout)
    local ok, line = pcall(function() return client:receive("*l") end)
    if not ok or not line then client:close(); return end

    local method, path = line:match("^(%S+)%s(%S+)")
    if not method or not path then client:close(); return end

    -- read headers
    local headers = {}
    while true do
        local l = client:receive("*l")
        if not l or l == "" then break end
        local k, v = l:match("^(%S+):%s*(.*)")
        if k and v then headers[k:lower()] = v end
    end

    local status_code, status_text, resp_headers, body = router.handle(method, path, headers)
    send_response(client, status_code or 500, status_text or "Internal", resp_headers, body)
    client:close()
end

while true do
    local client = server:accept()
    if client then
        -- handle connection in a simple, non-blocking way (single-threaded)
        local ok, err = pcall(handle_client, client)
        if not ok then
            print("Error handling client:", err)
            client:close()
        end
    else
        -- no connection right now; avoid busy spin
        socket.sleep(0.01)
    end
end
