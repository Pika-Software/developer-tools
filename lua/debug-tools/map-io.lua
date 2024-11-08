local surface = surface
local render = render
local hook = hook
local cam = cam

local ClientsideModel = ClientsideModel
local CreateMaterial = CreateMaterial
local file_Exists = file.Exists
local color_white = color_white
local IsValid = IsValid
local ipairs = ipairs
local EyePos = EyePos
local pairs = pairs
local Model = Model

local developer = GetConVar("developer")
local materialsCache = {}
local aliases = {
    ["env_fog_controller"] = "fog_controller",
    ["light_environment"] = "light_env"
}

local distance = CreateClientConVar("developer_io_distance", "2048", true, false,
        "Limiting the rendering distance of the map entities, the smaller, the better the performance.", 128, 16384)
    :GetInt() ^
    2
cvars.AddChangeCallback("developer_io_distance", function(_, __, value)
    distance = (tonumber(value) or 0) ^ 2
end, "Map-IO")

local ignoreZ = CreateClientConVar("developer_io_ignorez", "0", true, false, "Ignore Z for map entities. (ignore walls)",
    0, 1):GetBool()
cvars.AddChangeCallback("developer_io_ignorez", function(_, __, value)
    ignoreZ = value == "1"
end, "Map-IO")

local entities = {}

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

local doors = {
    ["prop_testchamber_door"] = true,
    ["prop_door_rotating"] = true,
    ["func_door_rotating"] = true,
    ["func_door"] = true
}

local windows = {
    ["func_breakable_surf"] = true,
    ["func_breakable"] = true,
    ["func_physbox"] = true
}

local infoNodes = {
    ["info_node"] = true,
    ["info_hint"] = true,
    ["info_node_hint"] = true,
    ["info_node_air_hint"] = true,
    ["info_node_air"] = true,
    ["info_node_climb"] = true
}

local spawnPoints = {
    -- Garry's Mod
    ["info_player_start"] = true,

    -- Garry's Mod (old)
    ["gmod_player_start"] = true,

    -- Half-Life 2: Deathmatch
    ["info_player_deathmatch"] = true,
    ["info_player_combine"] = true,
    ["info_player_rebel"] = true,

    -- Counter-Strike: Source & Counter-Strike: Global Offensive
    ["info_player_counterterrorist"] = true,
    ["info_player_terrorist"] = true,

    -- Day of Defeat: Source
    ["info_player_axis"] = true,
    ["info_player_allies"] = true,

    -- Team Fortress 2
    ["info_player_teamspawn"] = true,

    -- Insurgency
    ["ins_spawnpoint"] = true,

    -- AOC
    ["aoc_spawnpoint"] = true,

    -- Dystopia
    ["dys_spawn_point"] = true,

    -- Pirates, Vikings, and Knights II
    ["info_player_pirate"] = true,
    ["info_player_viking"] = true,
    ["info_player_knight"] = true,

    -- D.I.P.R.I.P. Warm Up
    ["diprip_start_team_blue"] = true,
    ["diprip_start_team_red"] = true,

    -- OB
    ["info_player_red"] = true,
    ["info_player_blue"] = true,

    -- Synergy
    ["info_player_coop"] = true,

    -- Zombie Panic! Source
    ["info_player_human"] = true,
    ["info_player_zombie"] = true,

    -- Zombie Master
    ["info_player_zombiemaster"] = true,

    -- Fistful of Frags
    ["info_player_fof"] = true,
    ["info_player_desperado"] = true,
    ["info_player_vigilante"] = true,

    -- Left 4 Dead & Left 4 Dead 2
    ["info_survivor_rescue"] = true,
    ["info_survivor_position"] = true
}

local ignore_props = CreateClientConVar("developer_io_ignore_props", "1", true, false, "Hide props.", 0, 1)
local ignore_doors = CreateClientConVar("developer_io_ignore_doors", "0", true, false, "Hide doors.", 0, 1)
local ignore_windows = CreateClientConVar("developer_io_ignore_windows", "0", true, false, "Hide windows.", 0, 1)
local ignore_info_nodes = CreateClientConVar("developer_io_ignore_info_nodes", "1", true, false, "Hide info nodes.", 0, 1)

local function mapIO()
    if developer:GetInt() < 4 then
        hook.Remove("PostDrawTranslucentRenderables", "Debug Tools: Map-IO")
        hook.Remove("Think", "Debug Tools: Map-IO")
        return
    end

    for index, data in pairs(entities) do
        local modelEntity = data.ModelEntity
        if IsValid(modelEntity) then
            modelEntity:Remove()
        end

        entities[index] = nil
    end

    local map = NikNaks.CurrentMap

    for _, entity in ipairs(map:GetEntities()) do
        local className = entity.classname
        if className ~= "worldspawn" and props[className] ~= ignore_props:GetBool() and doors[className] ~= ignore_doors:GetBool() and windows[className] ~= ignore_windows:GetBool() and infoNodes[className] ~= ignore_info_nodes:GetBool() then
            local data = {
                ["ClassName"] = className,
                ["HammerID"] = entity.hammerid,
                ["Name"] = entity.targetname,
                ["Target"] = entity.target,
                ["Origin"] = entity.origin,
                ["Angles"] = entity.angles,
                ["Model"] = entity.model
            }

            data.IsSpawnPoint = spawnPoints[data.ClassName]

            local light = entity._light
            if light then
                local color = string.Split(light, " ")
                data.Color = Color(color[1], color[2], color[3])
            end

            local renderColor = entity.rendercolor
            if renderColor then
                data.Color = Color(renderColor.r, renderColor.g, renderColor.b)
            end

            if not data.Color then
                data.Color = color_white
            end

            entities[#entities + 1] = data
        end
    end

    for i, data in ipairs(entities) do
        local target = data.Target
        if target ~= nil then
            for j, data2 in ipairs(entities) do
                if i == j then continue end

                if data2.Name ~= target then continue end
                data.TargetData = data2
                break
            end
        end
    end

    hook.Add("Think", "Debug Tools: Map-IO", function()
        local eyePos = EyePos()
        for _, data in ipairs(entities) do
            if data.IsSpawnPoint then
                if data.ModelEntity == nil then
                    local clientModel = ClientsideModel(Model("models/editor/playerstart.mdl"), RENDERGROUP_OTHER)
                    if IsValid(clientModel) then
                        clientModel:SetModel("models/editor/playerstart.mdl")
                        clientModel:SetNoDraw(true)
                        data.ModelEntity = clientModel
                    else
                        data.ModelEntity = false
                    end
                end

                local modelEntity = data.ModelEntity
                if modelEntity ~= false and IsValid(modelEntity) then
                    modelEntity:SetAngles(data.Angles)
                    modelEntity:SetColor(data.Color)
                    modelEntity:SetPos(data.Origin)
                end
            end

            data.IsVisible = eyePos:DistToSqr(data.Origin) <= distance and map:PVSCheck(data.Origin, eyePos)
            if not data.IsVisible then continue end

            local angle = (eyePos - data.Origin):Angle()
            angle:SetUnpacked(0, angle[2] + 90, angle[3] + 90)
            data.CameraAngle = angle
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", "Debug Tools: Map-IO", function()
        for _, data in ipairs(entities) do
            if not data.IsVisible then continue end
            local pos = data.Origin

            local target = data.TargetData
            if target ~= nil then
                render.DrawLine(pos, target.Origin, data.Color, not ignoreZ)
            end

            local modelEntity = data.ModelEntity
            if modelEntity ~= false and IsValid(modelEntity) then
                modelEntity:DrawModel()
                continue
            end

            if data.Sprite == nil then
                local className = aliases[data.ClassName] or data.ClassName
                local material = materialsCache[className]
                if material == nil then
                    if file_Exists("materials/editor/" .. className .. ".vtf", "GAME") then
                        material = CreateMaterial(className .. ":map-io", "Sprite", {
                            ["$basetexture"] = "editor/" .. className,
                            ["$spriteorientation"] = "vp_parallel",
                            ["$spriteorigin"] = "[ 0.50 0.50 ]",
                            ["$spriterendermode"] = 1
                        })

                        materialsCache[className] = material:IsError() and false or material
                    else
                        materialsCache[className] = false
                    end
                end

                data.Sprite = material
            elseif data.Sprite ~= false then
                cam.IgnoreZ(ignoreZ)
                render.SetMaterial(data.Sprite)
                render.DrawSprite(pos, 16, 16, data.Color)
                cam.IgnoreZ(false)
                continue
            end

            cam.IgnoreZ(ignoreZ)
            cam.Start3D2D(pos, data.CameraAngle, 0.1)
            surface.SetTextColor(255, 255, 255)
            surface.SetFont("DermaLarge")

            local width, height = surface.GetTextSize(data.ClassName)
            surface.SetTextPos(-width / 2, -height / 2)
            surface.DrawText(data.ClassName)
            cam.End3D2D()
            cam.IgnoreZ(false)
        end
    end)
end

cvars.AddChangeCallback("developer", function()
    timer.Simple(0, mapIO)
end, "Debug Tools: Map-IO")

mapIO()
