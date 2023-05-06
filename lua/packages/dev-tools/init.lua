import( "https://github.com/Nak2/NikNaks" )
if not NikNaks then require( "niknaks" ) end
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