local concommand = concommand
local logger = gpm.Logger
local IsValid = IsValid

concommand.Add( "developer_time", function()
    logger:Info( "Time: %s", os.date( "%H:%M:%S - %d/%m/%Y", os.time() ) )
    logger:Info( "CurTime: %s", string.FormattedTime( CurTime() / 60, "%02i:%02i:%02i" ) )
    logger:Info( "SysTime: %s", string.FormattedTime( SysTime() / 60, "%02i:%02i:%02i" ) )
    logger:Info( "OtherTime: %s", string.FormattedTime( ( SysTime() - CurTime() ) / 60, "%02i:%02i:%02i" ) )
end )

if CLIENT then return end

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
    if IsValid( wep ) then
        ply:StripWeapon( wep )
    end
end )