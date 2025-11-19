# automatic-octo-broccoli

Minimal Lua webserver example

Requirements:

- Lua 5.1+ (system `lua` or `lua5.3`/`lua5.4`)
- LuaSocket library (install via OS package manager or `luarocks install luasocket`)

Run:

```bash
# from project root
lua server.lua
```

Then open http://127.0.0.1:8080/ or `curl http://127.0.0.1:8080/`.

Static files: put files under `static/` and request `/static/<filename>`.
