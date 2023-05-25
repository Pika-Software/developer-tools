require( "packages/glua-extensions", "https://github.com/Pika-Software/glua-extensions" )
if not util.IsLuaModuleInstalled( "niknaks" ) then
    import( "https://github.com/Nak2/NikNaks" )
end

require( "niknaks" )

if not DevTools then _G.DevTools = {} end

if SERVER then
    AddCSLuaFile( "visual-debugger.lua" )
    AddCSLuaFile( "world-bounds.lua" )
    AddCSLuaFile( "commands.lua" )
    AddCSLuaFile( "map-io.lua" )
end

include( "commands.lua" )

if CLIENT then
    include( "visual-debugger.lua" )
    include( "world-bounds.lua" )
    include( "map-io.lua" )
end