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
    --#include "utilities.lua"
    local utils = require("utilities")
    local copyxform = utils.copyxform

    local buffer = require("string.buffer")

    local vector = obj.module("CameraTransform_K")

    local kKeyXform = "0e1ed7c9-af0e-4440-b903-eb36ba941ede"
    local kCacheImage = "cache:ad0476bd-2eaa-4852-80a6-5feda1dc7587-" .. obj.effect_id
    local kEpsilon = 1.0e-4

    local cache = buffer.new()

    influence = influence * 0.01

    if layer_reference == 0 then
        relations_parent_layer = math.max(relations_parent_layer, 0)
    else
        relations_parent_layer = math.max(obj.layer + relations_parent_layer, 0)
    end

    local target = "layer" .. relations_parent_layer

    if relations_parent_layer ~= 0 and relations_parent_layer ~= obj.layer then
        if obj.getvalue(target) then
            local t = 1.0
            local x, y, z = obj.getvalue(target .. ".pos")
            local rx, ry, rz = obj.getvalue(target .. ".angle")
            local sx, sy, sz = obj.getvalue(target .. ".scale")

            local props = {}
            copyxform(props, obj)

            if not obj.copybuffer(kCacheImage, "object") then
                print("@error", "Failed to copy buffer")
                obj.load("text", "")
                return
            end

            global[kKeyXform] = nil

            if obj.load("layer", relations_parent_layer, true) and global[kKeyXform] ~= nil then
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

            if not obj.copybuffer("object", kCacheImage) then
                print("@error", "Failed to copy buffer")
                obj.load("text", "")
                return
            end

            copyxform(obj, props)

            vector.compose(t, x, y, z, 0.0, rx, ry, rz, 21, sx, sy, sz)

            global[kKeyXform] = nil
        else
            print("@warn", "Object not found on layer " .. relations_parent_layer)
        end
    end

    global[kKeyXform] = cache
        :reset()
        :encode({ influence, obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.sx, obj.sy, obj.sz })
        :get()

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
