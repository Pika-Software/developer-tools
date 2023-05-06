local render = render
local hook = hook
local draw = draw
local hook = hook
local cam = cam

local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local table_Empty = table.Empty
local math_min = math.min
local IsValid = IsValid
local Vector = Vector
local ipairs = ipairs

local identifier = gpm.Package:GetIdentifier( "visual-debugger" )
local developer = GetConVar( "developer" )
local vector_zero = Vector()
local debugObject = {
    ["IsValid"] = false
}

local distance = 4096

local colors = {
    Color( 255, 0, 0 ),
    Color( 0, 255, 0 ),
    Color( 0, 0, 255 )
}

local axis = {
    "X+",
    "Y+",
    "Z+"
}

local angles = {
    Angle( 0, 0, 0 ),
    Angle( 0, 90, 0 ),
    Angle( -90, 90, 90 )
}

function DevTools.VisualDebugger()
    if developer:GetInt() < 2 then
        hook.Remove( "PostDrawOpaqueRenderables", identifier )
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
            table_Empty( debugObject )
            debugObject.IsValid = false
            return
        end

        -- Valid
        debugObject.IsValid = true

        -- Position & angles
        debugObject.Origin = entity:GetPos()
        debugObject.Angles = entity:GetAngles()

        -- OBB mins, maxs
        local mins, maxs = entity:OBBMins(), entity:OBBMaxs()
        debugObject.Mins = mins
        debugObject.Maxs = maxs

        -- Lines
        local box = ( maxs - mins )
        local lenght = math_min( box[1], box[2], box[3] ) / 4
        local startPos = entity:LocalToWorld( vector_zero )

        local lines = {}
        for index = 1, 3 do
            local vec = Vector()
            vec[ index ] = lenght
            lines[ index ] = { startPos, entity:LocalToWorld( vec ), entity:LocalToWorldAngles( angles[ index ] ) }
        end

        debugObject.Lines = lines

        -- Color
        debugObject.Color = entity:GetColor()
    end )

    hook.Add( "PostDrawOpaqueRenderables", identifier, function()
        if developer:GetInt() < 2 then return end
        if not debugObject.IsValid then return end

        render.DrawWireframeBox( debugObject.Origin, debugObject.Angles, debugObject.Mins, debugObject.Maxs, debugObject.Color, false )

        for index, data in ipairs( debugObject.Lines ) do
            local color = colors[ index ]
            render.DrawLine( data[1], data[2], color, false )

            cam.IgnoreZ( true )
                cam.Start3D2D( data[2], data[3], 0.1 )
                    draw.DrawText( axis[ index ], "Default", 0, 0, color, TEXT_ALIGN_CENTER )
                cam.End3D2D()
            cam.IgnoreZ( false )
        end
    end )

end

cvars.AddChangeCallback( "developer", function()
    util.NextTick( DevTools.VisualDebugger )
end, identifier )

DevTools.VisualDebugger()