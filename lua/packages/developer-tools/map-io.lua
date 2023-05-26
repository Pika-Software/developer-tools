local NikNaks = NikNaks
local surface = surface
local render = render
local hook = hook
local util = util
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

local identifier = gpm.Package:GetIdentifier( "map-io" )
local developer = GetConVar( "developer" )
local materialsCache = {}
local aliases = {
    ["env_fog_controller"] = "fog_controller",
    ["light_environment"] = "light_env"
}

local distance = CreateClientConVar( "developer_io_distance", "2048", true, false, "Limiting the rendering distance of the map entities, the smaller, the better the performance.", 128, 16384 ):GetInt() ^ 2
cvars.AddChangeCallback( "developer_io_distance", function( _, __, value )
    distance = ( tonumber( value ) or 0 ) ^ 2
end, identifier )

local ignoreZ = CreateClientConVar( "developer_io_ignorez", "0", true, false, "Ignore Z for map entities. (ignore walls)", 0, 1 ):GetBool()
cvars.AddChangeCallback( "developer_io_ignorez", function( _, __, value )
    ignoreZ = value == "1"
end, identifier )

local entities = DevTools.Entities
if not entities then
    entities = {}; DevTools.Entities = entities
end

function DevTools.MapIO()
    if developer:GetInt() < 4 then
        hook.Remove( "PostDrawTranslucentRenderables", identifier )
        hook.Remove( "HUDPaint", identifier )
        hook.Remove( "Think", identifier )
        return
    end

    for index, data in pairs( entities ) do
        local modelEntity = data.ModelEntity
        if IsValid( modelEntity ) then
            modelEntity:Remove()
        end

        entities[ index ] = nil
    end

    for index, entity in ipairs( NikNaks.CurrentMap:GetEntities() ) do
        local className = entity.classname
        if className == "worldspawn" then continue end
        if util.IsPropClass( className ) then continue end
        if util.IsDoorClass( className ) then continue end
        if util.IsWindowClass( className ) then continue end
        if util.IsInfoNodeClass( className ) then continue end

        local data = {
            ["ClassName"] = className,
            ["HammerID"] = entity.hammerid,
            ["Name"] = entity.targetname,
            ["Target"] = entity.target,
            ["Origin"] = entity.origin,
            ["Angles"] = entity.angles,
            ["Model"] = entity.model
        }

        data.IsSpawnPoint = util.IsSpawnPointClass( data.ClassName )

        local light = entity._light
        if light then
            local color = string.Split( light, " " )
            data.Color = Color( color[1], color[2], color[3] )
        end

        local renderColor = entity.rendercolor
        if renderColor then
            data.Color = Color( renderColor.r, renderColor.g, renderColor.b )
        end

        if not data.Color then
            data.Color = color_white
        end

        entities[ #entities + 1 ] = data
    end

    for i, data in ipairs( entities ) do
        local target = data.Target
        if target ~= nil then
            for j, data2 in ipairs( entities ) do
                if i == j then continue end

                if data2.Name ~= target then continue end
                data.TargetData = data2
                break
            end
        end
    end

    hook.Add( "Think", identifier, function()
        local eyePos = EyePos()
        for _, data in ipairs( entities ) do
            if data.IsSpawnPoint then
                if data.ModelEntity == nil then
                    local clientModel = ClientsideModel( Model( "models/editor/playerstart.mdl" ), RENDERGROUP_OTHER )
                    if IsValid( clientModel ) then
                        clientModel:SetModel( "models/editor/playerstart.mdl" )
                        clientModel:SetNoDraw( true )
                        data.ModelEntity = clientModel
                    else
                        data.ModelEntity = false
                    end
                end

                local modelEntity = data.ModelEntity
                if modelEntity ~= false and IsValid( modelEntity ) then
                    modelEntity:SetAngles( data.Angles )
                    modelEntity:SetColor( data.Color )
                    modelEntity:SetPos( data.Origin )
                end
            end

            data.IsVisible = eyePos:DistToSqr( data.Origin ) <= distance and NikNaks.PVS.IsPositionVisible( data.Origin, eyePos )
            if not data.IsVisible then continue end

            local angle = ( eyePos - data.Origin ):Angle()
            angle[1] = 0
            angle[2] = angle[2] + 90
            angle[3] = angle[3] + 90

            data.CameraAngle = angle
        end
    end )

    hook.Add( "PostDrawTranslucentRenderables", identifier, function()
        for _, data in ipairs( entities ) do
            if not data.IsVisible then continue end
            local pos = data.Origin

            local target = data.TargetData
            if target ~= nil then
                render.DrawLine( pos, target.Origin, data.Color, not ignoreZ )
            end

            local modelEntity = data.ModelEntity
            if modelEntity ~= false and IsValid( modelEntity ) then
                modelEntity:DrawModel()
                continue
            end

            if data.Sprite == nil then
                local className = aliases[ data.ClassName ] or data.ClassName
                local material = materialsCache[ className ]
                if material == nil then
                    if file_Exists( "materials/editor/" .. className .. ".vtf", "GAME" ) then
                        material = CreateMaterial( className .. ":map-io", "Sprite", {
                            ["$basetexture"] = "editor/" .. className,
                            ["$spriteorientation"] = "vp_parallel",
                            ["$spriteorigin"] = "[ 0.50 0.50 ]",
                            ["$spriterendermode"] = 1
                        } )

                        materialsCache[ className ] = material:IsError() and false or material
                    else
                        materialsCache[ className ] = false
                    end
                end

                data.Sprite = material
            elseif data.Sprite ~= false then
                cam.IgnoreZ( ignoreZ )
                    render.SetMaterial( data.Sprite )
                    render.DrawSprite( pos, 16, 16, data.Color )
                cam.IgnoreZ( false )
                continue
            end

            cam.IgnoreZ( ignoreZ )
                cam.Start3D2D( pos, data.CameraAngle, 0.1 )
                    surface.SetTextColor( 255, 255, 255 )
                    surface.SetFont( "DermaLarge" )

                    local width, height = surface.GetTextSize( data.ClassName )
                    surface.SetTextPos( -width / 2, -height / 2 )
                    surface.DrawText( data.ClassName )
                cam.End3D2D()
            cam.IgnoreZ( false )
        end
    end )
end

cvars.AddChangeCallback( "developer", function()
    util.NextTick( DevTools.MapIO )
end, identifier )

DevTools.MapIO()