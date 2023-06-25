name = "developer-tools"
version = 010101
autorun = true
init = {
    ["client"] = "cl_init.lua",
    ["server"] = "init.lua"
}
send = {
    "visual-debugger.lua",
    "world-bounds.lua",
    "shared.lua",
    "map-io.lua"
}