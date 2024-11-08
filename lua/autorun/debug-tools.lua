if file.Exists("includes/modules/niknaks.lua", "LUA") then
    require("niknaks")
else
    ErrorNoHalt("niknaks not found. Please install it first.\n")
    return
end

if SERVER then
    AddCSLuaFile("debug-tools/visual-debugger.lua")
    AddCSLuaFile("debug-tools/world-bounds.lua")
    AddCSLuaFile("debug-tools/commands.lua")
    AddCSLuaFile("debug-tools/map-io.lua")

    local function commandAccess(ply)
        return ply and ply:IsValid() and ply:IsSuperAdmin() and ply:IsFullyAuthenticated() or ply:IsListenServerHost()
    end

    concommand.Add("strip_weapons", function(ply)
        if commandAccess(ply) then
            ply:StripWeapons()
        end
    end)

    concommand.Add("strip_active_weapon", function(ply)
        if not commandAccess(ply) then return end

        local weapon = ply:GetActiveWeapon()
        if weapon and weapon:IsValid() then
            weapon:Remove()
        end
    end)
elseif CLIENT then
    include("debug-tools/visual-debugger.lua")
    include("debug-tools/world-bounds.lua")
    include("debug-tools/commands.lua")
    include("debug-tools/map-io.lua")
end

concommand.Add("developer_time", function()
    print(string.format("Time: %s", os.date("%H:%M:%S - %d/%m/%Y", os.time())))
    print(string.format("CurTime: %s", string.FormattedTime(CurTime() / 60, "%02i:%02i:%02i")))
    print(string.format("SysTime: %s", string.FormattedTime(SysTime() / 60, "%02i:%02i:%02i")))
    print(string.format("OtherTime: %s", string.FormattedTime((SysTime() - CurTime()) / 60, "%02i:%02i:%02i")))
end)
