local surface = surface
local render = render
local hook = hook
local hook = hook
local cam = cam

local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local util_TraceLine = util.TraceLine
local draw_DrawText = draw.DrawText
local table_Empty = table.Empty
local SortedPairs = SortedPairs
local LocalPlayer = LocalPlayer
local math_min = math.min
local IsValid = IsValid
local Vector = Vector
local ipairs = ipairs
local type = type
local ScrW = ScrW

local identifier = gpm.Package:GetIdentifier( "visual-debugger" )
local developer = GetConVar( "developer" )
local vector_zero = Vector()
local debugObject = {
    ["IsValid"] = false
}

local distance = 4096

local backgroundColor0 = Color( 25, 25, 25 )
local backgroundColor1 = Color( 50, 50, 50 )
local textColor = Color( 225, 225, 225 )

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

local function toString( any )
    local anyType = type( any )
    if anyType == "string" then
        return "\"" .. any .. "\""
    elseif anyType == "boolean" then
        return any and "true" or "false"
    elseif anyType == "number" then
        return tostring( any )
    elseif anyType == "Vector" then
        return "Vector( " .. math.Round( any[1], 2 ) .. ", " .. math.Round( any[2], 2 ) .. ", " .. math.Round( any[3], 2 ) .. " )"
    elseif anyType == "Angle" then
        return "Angle( " .. math.Round( any[1], 2 ) .. ", " .. math.Round( any[2], 2 ) .. ", " .. math.Round( any[3], 2 ) .. " )"
    elseif anyType == "Color" then
        return "Color( " .. any.r .. ", " .. any.g .. ", " .. any.b .. ", " .. any.a .. " )"
    else

        local func = any.__tostring
        if func ~= nil then
            return func( any )
        end

    end
end

local hud = {}
local hudBlacklist = {
    ["IsValid"] = true,
    ["Entity"] = true,
    ["Lines"] = true
}

function DevTools.VisualDebugger()
    if developer:GetInt() < 2 then
        hook.Remove( "PostDrawTranslucentRenderables", identifier )
        hook.Remove( "HUDPaint", identifier )
        hook.Remove( "Think", identifier )
        return
    end

    hook.Add( "Think", identifier, function()
        local ply = LocalPlayer()
        local start = ply:EyePos()
        local entity = util_TraceLine( {
            ["start"] = start,
            ["endpos"] = start + ply:EyeAngles():Forward() * distance,
            ["filter"] = ply
        } ).Entity

        if not IsValid( entity ) then
            entity = debugObject.Entity
        end

        if not IsValid( entity ) then
            if debugObject.IsValid then
                table_Empty( debugObject )
                debugObject.IsValid = false
            end

            return
        end

        debugObject.Entity = entity

        -- ID's
        debugObject.Index = entity:EntIndex()

        if entity:IsPlayer() then
            debugObject.UserID = entity:UserID()
        end

        -- Position & angles
        debugObject.Origin = entity:GetPos()
        debugObject.Angles = entity:GetAngles()

        -- OBB mins, maxs
        local mins, maxs = entity:OBBMins(), entity:OBBMaxs()
        debugObject.Mins = mins
        debugObject.Maxs = maxs

        -- Lines
        local box = ( maxs - mins )
        local length = math_min( box[1], box[2], box[3] ) / 4
        local startPos = entity:LocalToWorld( vector_zero )

        local lines = {}
        for index = 1, 3 do
            local vec = Vector()
            vec[ index ] = length
            lines[ index ] = { startPos, entity:LocalToWorld( vec ), entity:LocalToWorldAngles( angles[ index ] ) }
        end

        debugObject.Lines = lines

        -- Color
        debugObject.Color = entity:GetColor()

        -- Other
        debugObject.Model = entity:GetModel()
        debugObject.Velocity = entity:GetVelocity()
        debugObject.ClassName = entity:GetClass()
        debugObject.RenderGroup = entity:GetRenderGroup()
        debugObject.CollisionGroup = entity:GetCollisionGroup()
        debugObject.Language = entity:IsScripted() and "gLua" or "C++"

        -- Health
        do

            local health, maxHealth = entity:Health(), entity:GetMaxHealth()
            if health > 0 then
                debugObject.Health = health .. " / " .. maxHealth .. " [" .. math.Round( health / math.max( 1, maxHealth ) * 100, 2 ) .. "%]"
            end

        end

        -- NW Vars
        for key, value in pairs( entity:GetNWVarTable() ) do
            debugObject[ "[NW] " ..  key ] = value
        end

        table_Empty( hud )

        local width = 0
        for key, value in SortedPairs( debugObject ) do
            if hudBlacklist[ key ] then continue end

            value = toString( value )
            if not value then continue end

            local index = #hud
            local inverted = index % 2 ~= 0
            local text = key .. ": " .. value

            surface.SetFont( "Trebuchet24" )
            local textWidth, textHeight = surface.GetTextSize( text )
            if textWidth > width then width = textWidth end

            hud[ index + 1 ] = {
                ["Background"] = inverted and backgroundColor0 or backgroundColor1,
                ["TextColor"] = textColor,
                ["Height"] = textHeight,
                ["Width"] = textWidth,
                ["Y"] = 10 + textHeight * index,
                ["Text"] = text
            }
        end

        hud.Width = width + 10
        debugObject.IsValid = true
    end )

    hook.Add( "PostDrawTranslucentRenderables", identifier, function()
        if developer:GetInt() < 2 then return end
        if not debugObject.IsValid then return end

        render.DrawWireframeBox( debugObject.Origin, debugObject.Angles, debugObject.Mins, debugObject.Maxs, debugObject.Color, false )

        for index, data in ipairs( debugObject.Lines ) do
            local color = colors[ index ]
            render.DrawLine( data[1], data[2], color, false )

            cam.IgnoreZ( true )
                cam.Start3D2D( data[2], data[3], 0.1 )
                    draw_DrawText( axis[ index ], "Default", 0, 0, color, TEXT_ALIGN_CENTER )
                cam.End3D2D()
            cam.IgnoreZ( false )
        end
    end )

    hook.Add( "HUDPaint", identifier, function()
        if not debugObject.IsValid then return end
        local x = ScrW() - 10 - hud.Width

        for index, data in ipairs( hud ) do
            surface.SetAlphaMultiplier( 0.9 )
                surface.SetDrawColor( data.Background )
                surface.DrawRect( x, data.Y, hud.Width, data.Height )
            surface.SetAlphaMultiplier( 1 )

            surface.SetTextPos( x + ( hud.Width - data.Width ) / 2, data.Y )
            surface.SetTextColor( data.TextColor )
            surface.SetFont( "Trebuchet24" )
            surface.DrawText( data.Text )
        end
    end )
end

cvars.AddChangeCallback( "developer", function()
    util.NextTick( DevTools.VisualDebugger )
end, identifier )

DevTools.VisualDebugger()