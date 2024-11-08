local language_GetPhrase = language.GetPhrase
local game_GetAmmoName = game.GetAmmoName
local list_Get = list.Get
local ipairs = ipairs
local Msg = Msg

local getEntityType
do
    local type = type

    local props = {
        ["prop_physics_multiplayer"] = true,
        ["prop_physics_override"] = true,
        ["prop_dynamic_override"] = true,
        ["prop_dynamic"] = true,
        ["prop_ragdoll"] = true,
        ["prop_physics"] = true,
        ["prop_detail"] = true,
        ["prop_static"] = true
    }

    function getEntityType(entity)
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
        elseif props[entity:GetClass()] then
            return "Prop"
        end

        return type(entity)
    end
end

local function printEntityInfo(entity)
    Msg("\n")

    Msg(string.format("Type: \"%s\"\n", getEntityType(entity)))
    Msg(string.format("Index: %d\n", entity:EntIndex()))

    local className = entity:GetClass()
    Msg(string.format("Class: \"%s\"\n", className))
    Msg(string.format("Model: \"%s\"\n", entity:GetModel()))

    local origin = entity:GetPos()
    Msg(string.format("Origin: Vector( %d, %d, %d )\n", origin:Unpack()))

    local angle = entity:GetAngles()
    Msg(string.format("Angles: Angle( %d, %d, %d )\n", angle:Unpack()))

    local color = entity:GetColor()
    Msg(string.format("Color: Color( %d, %d, %d, %d )\n", color:Unpack()))
    Msg(string.format("Language: \"%s\"\n", entity:IsScripted() and "gLua" or "C++"))

    if entity:IsVehicle() then
        local vehicleClass = entity:GetVehicleClass()
        Msg(string.format("Vehicle Class: \"%s\"\n", vehicleClass))

        local data = list_Get("Vehicles")[vehicleClass]
        Msg(string.format("Vehicle Model: \"%s\"\n", data.Model))
        Msg(string.format("Name: \"%s\"\n", language_GetPhrase(data.Name)))
        Msg(string.format("Information: \"%s\"\n", language_GetPhrase(data.Information)))
        Msg(string.format("Author: \"%s\"\n", data.Author))
    elseif entity:IsNPC() then
        local data = list_Get("NPC")[className]
        Msg(string.format("Name: \"%s\"\n", language_GetPhrase(data.Name)))

        local weapon = entity:GetActiveWeapon()
        if weapon and weapon:IsValid() then
            Msg(string.format("Weapon: \"%s\"\n",
                language_GetPhrase(weapon:GetPrintName() or weapon.PrintName or "Scripted Weapon") ..
                " (" .. weapon:GetClass() .. ")"))
        else
            Msg("Weapon: none\n")
        end
    elseif entity:IsWeapon() then
        Msg(string.format("PrintName: \"%s\"\n", language_GetPhrase(entity:GetPrintName() or entity.PrintName)))
        Msg(string.format("HoldType: \"%s\"\n", entity:GetHoldType()))
        Msg(string.format("Clip1: %d/%d (%s)\n", entity:Clip1(), entity:GetMaxClip1(),
            game_GetAmmoName(entity:GetPrimaryAmmoType()) or "nil"))
        Msg(string.format("Clip2: %d/%d (%s)\n", entity:Clip2(), entity:GetMaxClip2(),
            game_GetAmmoName(entity:GetSecondaryAmmoType()) or "nil"))
        Msg(string.format("SlotPos: %d\n", entity:GetSlotPos()))
        Msg(string.format("Slot: %d\n", entity:GetSlot()))
    elseif entity.PrintName ~= nil then
        Msg(string.format("PrintName: \"%s\"\n", language_GetPhrase(entity.PrintName)))
    end

    if entity.GetFlexNum ~= nil then
        local count = entity:GetFlexNum()
        if count > 0 then
            local flexes = "\n"
            for id = 0, count do
                flexes = flexes .. "\t[" .. id .. "] = \"" .. (entity:GetFlexName(id) or "") .. "\",\n"
            end

            Msg(string.format("Flexes: {%s}\n", flexes))
        end
    end

    if entity.GetBodyGroups ~= nil then
        local bodygroups = "\n"
        for _, data in ipairs(entity:GetBodyGroups()) do
            bodygroups = bodygroups ..
                "\t[\"" ..
                data.name ..
                "\"] = {\n\t\t[\"ID\"] = " .. data.id .. ",\n\t\t[\"Amount subgroups\"] = " .. data.num .. ",\n\t},\n"
        end

        Msg(string.format("Bodygroups: {%s}\n", bodygroups))
    end

    Msg("\n")
end

concommand.Add("developer_entity", function(ply)
    printEntityInfo(ply:GetEyeTrace().Entity)
end)

concommand.Add("developer_weapon", function(ply)
    local entity = ply:GetEyeTrace().Entity
    if entity and entity:IsValid() and entity:IsPlayer() or entity:IsNPC() then
        ply = entity
    end

    local weapon = ply:GetActiveWeapon()
    if weapon and weapon:IsValid() then
        printEntityInfo(weapon)
    end
end)

concommand.Add("developer_weapons", function(ply)
    local entity = ply:GetEyeTrace().Entity
    if entity and entity:IsValid() and entity:IsPlayer() then
        ply = entity
    end

    for index, weapon in ipairs(ply:GetWeapons()) do
        Msg(index .. ". ")
        printEntityInfo(weapon)
    end
end)
