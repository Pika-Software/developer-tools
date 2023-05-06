local identifier = gpm.Package:GetIdentifier( "visual-debugger" )
local developer = GetConVar( "developer" )
local debugObject = {
    ["IsValid"] = false
}

local distance = 4096

function DevTools.VisualDebugger()
    if developer:GetInt() < 4 then
        hook.Remove( "PostDrawOpaqueRenderables", identifier )
        hook.Remove( "HUDPaint", identifier )
        hook.Remove( "Think", identifier )
        return
    end

    hook.Add( "Think", identifier, function()
        local start = EyePos()
        local entity = util.TraceLine( {
            ["start"] = start,
            ["endpos"] = start + EyeAngles():Forward() * distance,
            ["filter"] = LocalPlayer()
        } ).Entity

        if IsValid( entity ) then
            local index = entity:EntIndex()
            if index ~= debugObject.Index then
                debugObject.Index = index
                debugObject.Entity = entity
                return
            end
        end

        entity = debugObject.Entity
        if not IsValid( entity ) then
            table.Empty( debugObject )
            debugObject.IsValid = false
            return
        end

        -- Valid
        debugObject.IsValid = true

        -- Position & angles
        debugObject.Origin = entity:GetPos()
        debugObject.Angles = entity:GetAngles()

        -- OBB
        debugObject.Center = entity:OBBCenter()
        debugObject.Mins = entity:OBBMins()
        debugObject.Maxs = entity:OBBMaxs()

        -- Color
        debugObject.Color = entity:GetColor()
    end )

    hook.Add( "PostDrawOpaqueRenderables", identifier, function()
        if developer:GetInt() < 2 then return end
        if not debugObject.IsValid then return end

        render.DrawWireframeBox( debugObject.Origin, debugObject.Angles, debugObject.Mins, debugObject.Maxs, debugObject.Color, false )
    end )

    hook.Add( "HUDPaint", identifier, function()
        if developer:GetInt() < 2 then return end
        if not debugObject.IsValid then return end

    end )

end

cvars.AddChangeCallback( "developer", function()
    util.NextTick( DevTools.VisualDebugger )
end, identifier )

DevTools.VisualDebugger()