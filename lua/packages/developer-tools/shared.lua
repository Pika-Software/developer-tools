install( "packages/glua-extensions", "https://github.com/Pika-Software/glua-extensions" )
install( "niknaks", "https://github.com/Nak2/NikNaks" )

if not DevTools then
    DevTools = {}
end

local concommand = concommand
local logger = gpm.Logger

concommand.Add( "developer_time", function()
    logger:Info( "Time: %s", os.date( "%H:%M:%S - %d/%m/%Y", os.time() ) )
    logger:Info( "CurTime: %s", string.FormattedTime( CurTime() / 60, "%02i:%02i:%02i" ) )
    logger:Info( "SysTime: %s", string.FormattedTime( SysTime() / 60, "%02i:%02i:%02i" ) )
    logger:Info( "OtherTime: %s", string.FormattedTime( ( SysTime() - CurTime() ) / 60, "%02i:%02i:%02i" ) )
end )

if SERVER then return end

local language_GetPhrase = language.GetPhrase
local game_GetAmmoName = game.GetAmmoName
local list_Get = list.Get
local IsValid = IsValid
local ipairs = ipairs
local type = type
local MsgN = MsgN
local Msg = Msg

local function getEntityType( entity )
    if entity:IsVehicle() then
        return "Vehicle"
    elseif entity:IsWeapon() then
        return "Weapon"
    elseif entity:IsNPC() then
        return "NPC"
    elseif entity:GetClass() == "prop_effect" then
        return "Effect"
    elseif entity:IsRagdoll() then
        return "Ragdoll"
    elseif entity:IsProp() then
        return "Prop"
    end

    return type( entity )
end

local function printEntityInfo( entity )
    MsgN()

    logger:Info( "Type: \"%s\"", getEntityType( entity ) )
    logger:Info( "Index: %d", entity:EntIndex() )

    local className = entity:GetClass()
    logger:Info( "Class: \"%s\"", className )
    logger:Info( "Model: \"%s\"", entity:GetModel() )

    local origin = entity:GetPos()
    logger:Info( "Origin: Vector( %d, %d, %d )", origin[1], origin[2], origin[3] )

    local angle = entity:GetAngles()
    logger:Info( "Angles: Angle( %d, %d, %d )", angle[1], angle[2], angle[3] )

    local color = entity:GetColor()
    logger:Info( "Color: Color( %d, %d, %d, %d )", color.r, color.g, color.b, color.a )
    logger:Info( "Language: \"%s\"", entity:IsScripted() and "gLua" or "C++" )

    if entity:IsVehicle() then
        local vehicleClass = entity:GetVehicleClass()
        logger:Info( "Vehicle Class: \"%s\"", vehicleClass )

        local data = list_Get( "Vehicles" )[ vehicleClass ]
        logger:Info( "Vehicle Model: \"%s\"", data.Model )
        logger:Info( "Name: \"%s\"", language_GetPhrase( data.Name ) )
        logger:Info( "Information: \"%s\"", language_GetPhrase( data.Information ) )
        logger:Info( "Author: \"%s\"", data.Author )
    elseif entity:IsNPC() then
        local data = list_Get( "NPC" )[ className ]
        logger:Info( "Name: \"%s\"", language_GetPhrase( data.Name ) )

        local wep = entity:GetActiveWeapon()
        if IsValid( wep ) then
            logger:Info( "Weapon: \"%s\"", language_GetPhrase( wep:GetPrintName() or wep.PrintName or "Scripted Weapon" ) .. " (" .. wep:GetClass() .. ")" )
        else
            logger:Info( "Weapon: nil" )
        end
    elseif entity:IsWeapon() then
        logger:Info( "PrintName: \"%s\"", language_GetPhrase( entity:GetPrintName() or entity.PrintName ) )
        logger:Info( "HoldType: \"%s\"", entity:GetHoldType() )
        logger:Info( "Clip1: %d/%d (%s)", entity:Clip1(), entity:GetMaxClip1(), game_GetAmmoName( entity:GetPrimaryAmmoType() ) or "nil" )
        logger:Info( "Clip2: %d/%d (%s)", entity:Clip2(), entity:GetMaxClip2(), game_GetAmmoName( entity:GetSecondaryAmmoType() ) or "nil" )
        logger:Info( "SlotPos: %d", entity:GetSlotPos() )
        logger:Info( "Slot: %d", entity:GetSlot() )
    elseif entity.PrintName ~= nil then
        logger:Info( "PrintName: \"%s\"", language_GetPhrase( entity.PrintName ) )
    end

    if entity.GetFlexNum ~= nil then
        local count = entity:GetFlexNum()
        if count > 0 then
            local flexes = "\n"
            for id = 0, count do
                flexes = flexes .. "\t[" .. id .. "] = \"" .. ( entity:GetFlexName( id ) or "" ) .. "\",\n"
            end

            logger:Info( "Flexes: {%s}", flexes )
        end
    end

    if entity.GetBodyGroups ~= nil then
        local tbl = entity:GetBodyGroups()
        if #tbl > 0 then
            local bodygroups = "\n"
            for num, data in ipairs( tbl ) do
                bodygroups = bodygroups .. "\t[\"" .. data.name .. "\"] = {\n\t\t[\"ID\"] = " .. data.id .. ",\n\t\t[\"Amount subgroups\"] = " .. data.num .. ",\n\t},\n"
            end

            logger:Info( "Bodygroups: {%s}", bodygroups )
        end
    end

    MsgN()
end

concommand.Add( "developer_entity", function( ply )
    printEntityInfo( ply:GetEyeTrace().Entity )
end )

concommand.Add( "developer_weapon", function( ply )
    local tr = ply:GetEyeTrace()
    local entity = tr.Entity
    if IsValid( entity ) and entity:IsPlayer() or entity:IsNPC() then
        ply = entity
    end

    local wep = ply:GetActiveWeapon()
    if not IsValid( wep ) then return end
    printEntityInfo( wep )
end )

concommand.Add( "developer_weapons", function( ply )
    local tr = ply:GetEyeTrace()
    local entity = tr.Entity
    if IsValid( entity ) and entity:IsPlayer() then
        ply = entity
    end

    for num, wep in ipairs( ply:GetWeapons() ) do
        Msg( num .. ". " )
        printEntityInfo( wep )
    end
end )
