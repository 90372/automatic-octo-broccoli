local static = require("static")

local M = {}

local function default_headers()
    return { ["Server"] = "lua-simple-http", ["Connection"] = "close" }
end

function M.handle(method, path, headers)
    -- simple routing
    if path == "/" then
        local body = "<h1>Hello from Lua webserver</h1>\n"
        local h = default_headers()
        h["Content-Type"] = "text/html; charset=utf-8"
        return 200, "OK", h, body
    end

    local static_prefix = "/static/"
    if path:sub(1, #static_prefix) == static_prefix then
        local rel = path:sub(#static_prefix + 1)
        local ok, status_code, status_text, resp_headers, body = static.serve(rel)
        if ok then
            return status_code, status_text, resp_headers, body
        end
        -- static returned not ok -> fallthrough to 404
    end

    local body = "404 Not Found\n"
    local h = default_headers()
    h["Content-Type"] = "text/plain; charset=utf-8"
    return 404, "Not Found", h, body
end

return M
