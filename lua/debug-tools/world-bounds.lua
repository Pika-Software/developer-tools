local worldColor = { r = 225, g = 125, b = 25 }
local developer = GetConVar("developer")

local worldAxis, boundMaterial, beamMaterial

local function worldBoundsRendering()
    if developer:GetInt() < 5 then
        hook.Remove("PreDrawEffects", "Debug Tools: World-Bounds")

        if worldAxis and worldAxis:IsValid() then
            worldAxis:Remove()
        end

        return
    end

    if not (worldAxis and worldAxis:IsValid()) then
        worldAxis = ClientsideModel(Model("models/editor/axis_helper.mdl"), RENDERGROUP_OTHER)
        worldAxis:SetNoDraw(true)
    end

    local map = NikNaks.CurrentMap
    local mins, maxs = map:WorldMin(), map:WorldMax()

    local top = {
        Vector(mins[1], mins[2], maxs[3]),
        Vector(mins[1], maxs[2], maxs[3]),
        Vector(maxs[1], maxs[2], maxs[3]),
        Vector(maxs[1], mins[2], maxs[3])
    }

    local bottom = {
        Vector(mins[1], mins[2], mins[3]),
        Vector(mins[1], maxs[2], mins[3]),
        Vector(maxs[1], maxs[2], mins[3]),
        Vector(maxs[1], mins[2], mins[3])
    }

    boundMaterial = boundMaterial or Material("sprites/gmdm_pickups/light")
    beamMaterial = beamMaterial or Material("cable/new_cable_lit")
    local render, cam = render, cam

    hook.Add("PreDrawEffects", "Debug Tools: World-Bounds", function()
        cam.IgnoreZ(true)
        render.SetMaterial(boundMaterial)

        -- Top bounds
        for i = 1, 4 do
            render.DrawSprite(top[i], 512, 512, worldColor)
        end

        -- Bottom bounds
        for i = 1, 4 do
            render.DrawSprite(bottom[i], 512, 512, worldColor)
        end

        render.SetMaterial(beamMaterial)

        -- Top Lines
        render.DrawBeam(top[1], top[2], 8, 0, 12, worldColor)
        render.DrawBeam(top[2], top[3], 8, 0, 12, worldColor)
        render.DrawBeam(top[3], top[4], 8, 0, 12, worldColor)
        render.DrawBeam(top[4], top[1], 8, 0, 12, worldColor)

        -- Bottom Lines
        render.DrawBeam(bottom[1], bottom[2], 8, 0, 12, worldColor)
        render.DrawBeam(bottom[2], bottom[3], 8, 0, 12, worldColor)
        render.DrawBeam(bottom[3], bottom[4], 8, 0, 12, worldColor)
        render.DrawBeam(bottom[4], bottom[1], 8, 0, 12, worldColor)

        -- Vertical Lines
        render.DrawBeam(bottom[1], top[1], 8, 0, 12, worldColor)
        render.DrawBeam(bottom[2], top[2], 8, 0, 12, worldColor)
        render.DrawBeam(bottom[3], top[3], 8, 0, 12, worldColor)
        render.DrawBeam(bottom[4], top[4], 8, 0, 12, worldColor)

        -- Axis
        if worldAxis and worldAxis:IsValid() then
            worldAxis:DrawModel()
        end

        cam.IgnoreZ(false)
    end)
end

cvars.AddChangeCallback("developer", function()
    timer.Simple(0, worldBoundsRendering)
end, "Debug Tools: World-Bounds")

worldBoundsRendering()
