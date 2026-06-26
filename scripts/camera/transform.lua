--@Transform

--require:${PROJECT_REQUIRES_AVIUTL2}
--information:Transform@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}

--group:Position,true
local position_x = 0.0 --track@position_x:Position::X,-100000,100000,0,0.01
local position_y = 0.0 --track@position_y:Position::Y,-100000,100000,0,0.01
local position_z = 0.0 --track@position_z:Position::Z,-100000,100000,0,0.01
--trackgroup@position_x,position_y,position_z:Group::Position
--group:Rotation,true
local rotation_w = 0.0 --track@rotation_w:Rotation::W,-3600,3600,0,0.01
local rotation_x = 0.0 --track@rotation_x:Rotation::X,-3600,3600,0,0.01
local rotation_y = 0.0 --track@rotation_y:Rotation::Y,-3600,3600,0,0.01
local rotation_z = 0.0 --track@rotation_z:Rotation::Z,-3600,3600,0,0.01
--#define EULER XYZ Euler=5,XZY Euler=7,YXZ Euler=11,YZX Euler=15,ZXY Euler=19,ZYX Euler=21
local rotation_mode = 21 --select@rotation_mode:Rotation::Mode=21,Quaternion=0,Axis Angle=1,${EULER}
--trackgroup@rotation_x,rotation_y,rotation_z:Group::Rotation
--group:Scale,true
local scale_x = 100.0 --track@scale_x:Scale::X,0,10000,100,0.01
local scale_y = 100.0 --track@scale_y:Scale::Y,0,10000,100,0.01
local scale_z = 100.0 --track@scale_z:Scale::Z,0,10000,100,0.01
--trackgroup@scale_x,scale_y,scale_z:Group::Scale
--group:Relations,true
local relations_parent_layer = 0 --track@relations_parent_layer:Relations::Parent Layer,-100,100,0,1,---
--group:Additional Operations,false
local influence = 100.0 --track@influence:Influence,0,100,100,0.01
local layer_reference = 0 --select@layer_reference:Layer Reference=0,Absolute=0,Relative=1

do
    local buffer = require("string.buffer")

    local vector = obj.module("CameraTransform_K")

    local kKeyXform = "0e1ed7c9-af0e-4440-b903-eb36ba941ede"

    local cache = buffer.new()

    scale_x = scale_x * 0.01
    scale_y = scale_y * 0.01
    scale_z = scale_z * 0.01

    influence = influence * 0.01

    if layer_reference == 0 then
        relations_parent_layer = math.max(relations_parent_layer, 0)
    else
        relations_parent_layer = math.max(obj.layer + relations_parent_layer, 0)
    end

    vector.reset()

    do
        local target = "layer" .. relations_parent_layer

        if relations_parent_layer ~= 0 and relations_parent_layer ~= obj.layer and obj.getvalue(target) then
            local t = 1.0
            local x, y, z = obj.getvalue(target .. ".pos")
            local rx, ry, rz = obj.getvalue(target .. ".angle")
            local sx, sy, sz = obj.getvalue(target .. ".scale")

            if global[kKeyXform] ~= nil and obj.load("layer", relations_parent_layer, true) then
                local xform = cache:set(global[kKeyXform]):decode()

                if type(xform) == "table" and #xform == 10 then
                    t = tonumber(xform[1]) or 1.0
                    x = x + (tonumber(xform[2]) or 0.0)
                    y = y + (tonumber(xform[3]) or 0.0)
                    z = z + (tonumber(xform[4]) or 0.0)
                    rx = rx + (tonumber(xform[5]) or 0.0)
                    ry = ry + (tonumber(xform[6]) or 0.0)
                    rz = rz + (tonumber(xform[7]) or 0.0)
                    sx = sx * (tonumber(xform[8]) or 1.0)
                    sy = sy * (tonumber(xform[9]) or 1.0)
                    sz = sz * (tonumber(xform[10]) or 1.0)
                end
            end

            vector.compose(t, x, y, z, 0.0, rx, ry, rz, 21, sx, sy, sz)
        end
    end

    vector.compose(
        influence,
        position_x,
        position_y,
        position_z,
        rotation_w,
        rotation_x,
        rotation_y,
        rotation_z,
        rotation_mode,
        scale_x,
        scale_y,
        scale_z
    )

    local props = obj.getoption("camera_param")

    local up = vector.rotate({ props.ux, props.uy, props.uz })
    local to, pos = vector.transform({ props.tx, props.ty, props.tz }, { props.x, props.y, props.z })

    props.ux, props.uy, props.uz = up[1], up[2], up[3]
    props.tx, props.ty, props.tz = to[1], to[2], to[3]
    props.x, props.y, props.z = pos[1], pos[2], pos[3]

    obj.setoption("camera_param", props)
end
