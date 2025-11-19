local config = require("config")
local lfs = nil

local M = {}

local function join_paths(a, b)
    if a:sub(-1) == "/" then return a .. b end
    return a .. "/" .. b
end

local function content_type_for(name)
    local ext = name:match("%.([%w]+)$") or ""
    ext = ext:lower()
    local map = {
        html = "text/html; charset=utf-8",
        htm = "text/html; charset=utf-8",
        txt = "text/plain; charset=utf-8",
        css = "text/css",
        js = "application/javascript",
        png = "image/png",
        jpg = "image/jpeg",
        jpeg = "image/jpeg",
        gif = "image/gif",
        json = "application/json",
    }
    return map[ext] or "application/octet-stream"
end

function M.serve(rel)
    local dir = config.StaticDir or "static"
    if rel:find('%.%./') then
        return false, 400, "Bad Request", { ["Content-Type"] = "text/plain" }, "Bad Request\n"
    end
    local path = join_paths(dir, rel)
    local f, err = io.open(path, "rb")
    if not f then
        return false, 404, "Not Found", { ["Content-Type"] = "text/plain" }, "Not Found\n"
    end
    local body = f:read("*a")
    f:close()
    local headers = { ["Content-Type"] = content_type_for(path) }
    return true, 200, "OK", headers, body
end

return M
