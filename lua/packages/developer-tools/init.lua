AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

AddCSLuaFile( "visual-debugger.lua" )
AddCSLuaFile( "world-bounds.lua" )
AddCSLuaFile( "map-io.lua" )

do

    local commandAccess = function( ply )
        return IsValid( ply ) and ply:IsSuperAdmin() and ply:IsFullyAuthenticated() or ply:IsListenServerHost()
    end

    local IsValid = IsValid

    concommand.Add( "strip_weapons", function( ply, cmd, args )
        if not commandAccess( ply ) then return end
        ply:StripWeapons()
    end )

    concommand.Add( "strip_active_weapon", function( ply, cmd, args )
        if not commandAccess( ply ) then return end

        local wep = ply:GetActiveWeapon()
        if not IsValid( wep ) then return end
        ply:StripWeapon( wep )
    end )

end