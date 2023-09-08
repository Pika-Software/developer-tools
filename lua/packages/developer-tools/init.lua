include( "shared.lua" )

local IsValid = IsValid

local function commandAccess( ply )
    return IsValid( ply ) and ply:IsSuperAdmin() and ply:IsFullyAuthenticated() or ply:IsListenServerHost()
end

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
