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
--group:Additional Options,false
local influence = 100.0 --track@influence:Influence,0,100,100,0.01
local layer_reference = 0 --select@layer_reference:Layer Reference=0,Absolute=0,Relative=1

do
    --#include "../parent.lua"
    local parent = require("parent")
    local compose = parent.compose

    local vector = obj.module("${SCRIPT_NAME}")

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

    if relations_parent_layer ~= 0 and relations_parent_layer ~= obj.layer then
        compose(relations_parent_layer)
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

    do
        local camera = obj.getoption("camera_param")
        local focus = obj.getoption("camera_focus")

        local up = vector.rotate({ camera.ux, camera.uy, camera.uz })
        local to, pos = vector.transform({ camera.tx, camera.ty, camera.tz }, { camera.x, camera.y, camera.z })

        camera.ux, camera.uy, camera.uz = up[1], up[2], up[3]
        camera.tx, camera.ty, camera.tz = to[1], to[2], to[3]
        camera.x, camera.y, camera.z = pos[1], pos[2], pos[3]

        focus.x, focus.y, focus.z = to[1], to[2], to[3]

        obj.setoption("camera_param", camera)
        obj.setoption("camera_focus", focus)
    end
end
