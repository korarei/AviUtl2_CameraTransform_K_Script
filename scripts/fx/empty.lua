--@Empty

--require:${PROJECT_REQUIRES_AVIUTL2}
--information:Empty@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}

--group:Relations,true
local relations_parent_layer = 0 --track@relations_parent_layer:Relations::Parent Layer,-100,100,0,1,---
--group:Visibility,true
--separator:Show In
local visibility_show_in_viewports = true --check@visibility_show_in_viewports:Visibility::Show In::Viewports,true
local visibility_show_in_renders = false --check@visibility_show_in_renders:Visibility::Show In::Renders,false
--group:Additional Operations,false
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

    local vector = obj.module("CameraTransform_K")

    local kCacheImage = "cache:ad0476bd-2eaa-4852-80a6-5feda1dc7587-" .. obj.effect_id
    local kEpsilon = 1.0e-4

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

    global[kKeyXform] =
        buffer.encode({ influence, obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.sx, obj.sy, obj.sz })

    if obj.getinfo("saving") and not visibility_show_in_renders or not visibility_show_in_viewports then
        obj.clearbuffer("object", 1, 1, 0)
        obj.alpha = 0.01
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
