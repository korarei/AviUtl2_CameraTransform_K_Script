--@Empty

--require:${PROJECT_REQUIRES_AVIUTL2}
--information:Empty@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
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
--group:Visibility,true
--separator:Show In
local visibility_show_in_viewports = true --check@visibility_show_in_viewports:Visibility::Show In::Viewports,true
local visibility_show_in_renders = false --check@visibility_show_in_renders:Visibility::Show In::Renders,false
--group:Additional Options,false
local influence = 100.0 --track@influence:Influence,0,100,100,0.01
local layer_reference = 0 --select@layer_reference:Layer Reference=0,Absolute=0,Relative=1

if obj.num ~= 1 then
    print("@error", "This script only supports a single object")
    return
end

do
    --#include "../parent.lua"
    local parent = require("parent")
    local kKeyXform, compose = parent.kKeyXform, parent.compose

    --#include "utilities.lua"
    local utils = require("utilities")
    local copyxform, stop = utils.copyxform, utils.stop

    local buffer = require("string.buffer")

    local vector = obj.module("${SCRIPT_NAME}")

    local kCacheImage = "cache:ad0476bd-2eaa-4852-80a6-5feda1dc7587-" .. obj.effect_id
    local kEpsilon = 1.0e-4

    scale_x = scale_x * 0.01
    scale_y = scale_y * 0.01
    scale_z = scale_z * 0.01

    influence = influence * 0.01

    if layer_reference == 0 then
        relations_parent_layer = math.max(relations_parent_layer, 0)
    else
        relations_parent_layer = math.max(obj.layer + relations_parent_layer, 0)
    end

    if relations_parent_layer ~= 0 and relations_parent_layer ~= obj.layer then
        local xform = {}
        copyxform(xform, obj)

        if not obj.copybuffer(kCacheImage, "object") then
            stop("Failed to copy buffer")
            return
        end

        compose(relations_parent_layer)

        if not obj.copybuffer("object", kCacheImage) then
            stop("Failed to copy buffer")
            return
        end

        copyxform(obj, xform)
    else
        vector.reset()
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

    global[kKeyXform] =
        buffer.encode({ influence, obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.sx, obj.sy, obj.sz })

    local is_rendering = obj.getinfo("saving")

    if is_rendering and not visibility_show_in_renders or (not is_rendering and not visibility_show_in_viewports) then
        obj.clearbuffer("object", 1, 1, 0)
        obj.alpha = kEpsilon
        obj.setoption("focus_mode", "fixed_size")
    else
        local x, y, z = obj.getvalue("pos")
        local rx, ry, rz = obj.getvalue("angle")
        local sx, sy, sz = obj.getvalue("scale")

        sx, sy, sz = math.max(sx, kEpsilon), math.max(sy, kEpsilon), math.max(sz, kEpsilon)

        local xform = vector.transform({
            influence,
            obj.ox + x,
            obj.oy + y,
            obj.oz + z,
            0.0,
            obj.rx + rx,
            obj.ry + ry,
            obj.rz + rz,
            21,
            obj.sx * sx,
            obj.sy * sy,
            obj.sz * sz,
        })

        obj.ox, obj.oy, obj.oz = xform[1] - x, xform[2] - y, xform[3] - z
        obj.rx, obj.ry, obj.rz = xform[5] - rx, xform[6] - ry, xform[7] - rz
        obj.sx, obj.sy, obj.sz = xform[9] / sx, xform[10] / sy, xform[11] / sz
    end
end
