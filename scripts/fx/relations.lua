--@Relations

--require:${PROJECT_REQUIRES_AVIUTL2}
--information:Relations@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}

local parent_layer = 0 --track@parent_layer:Parent Layer,-100,100,0,1,---
--group:Additional Options,false
local influence = 100.0 --track@influence:Influence,0,100,100,0.01
local layer_reference = 0 --select@layer_reference:Layer Reference=0,Absolute=0,Relative=1

do
    --#include "../parent.lua"
    local parent = require("parent")
    local compose = parent.compose

    --#include "utilities.lua"
    local utils = require("utilities")
    local copyxform, stop = utils.copyxform, utils.stop

    local vector = obj.module("${SCRIPT_NAME}")

    local kCacheImage = "cache:9f8eddfa-19d0-453c-b64b-c658e3099de5-" .. obj.effect_id
    local kEpsilon = 1.0e-4

    influence = influence * 0.01

    if layer_reference == 0 then
        parent_layer = math.max(parent_layer, 0)
    else
        parent_layer = math.max(obj.layer + parent_layer, 0)
    end

    if parent_layer == 0 or parent_layer == obj.layer then
        return
    end

    vector.reset()

    do
        local xform = {}
        copyxform(xform, obj)

        if not obj.copybuffer(kCacheImage, "object") then
            stop("Failed to copy buffer")
            return
        end

        compose(parent_layer)

        if not obj.copybuffer("object", kCacheImage) then
            stop("Failed to copy buffer")
            return
        end

        copyxform(obj, xform)
    end

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
