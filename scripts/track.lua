--@Track

--require:${PROJECT_REQUIRES_AVIUTL2}
--information:Track@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}

local target_layer = 0 --track@target_layer:Target Layer,-100,100,1,1,---
local track_axis = 3 --select@track_axis:Track Axis=3,-Z=-3,-Y=-2,-X=-1,X=1,Y=2,Z=3
--group:Additional Options,false
local influence = 100 --track@influence:Influence,0,100,100,0.01
local layer_reference = 0 --select@layer_reference:Layer Reference,Absolute=0,Relative=1

do
    local buffer = require("string.buffer")

    local vector = obj.module("CameraTransform_K")

    local kKeyXform = "0e1ed7c9-af0e-4440-b903-eb36ba941ede"

    local cache = buffer.new()

    influence = influence * 0.01

    if layer_reference == 0 then
        target_layer = math.max(target_layer, 0)
    else
        target_layer = math.max(obj.layer + target_layer, 0)
    end

    local target = "layer" .. target_layer

    if target_layer == 0 or target_layer == obj.layer or not obj.getvalue(target) then
        return
    end

    vector.reset()

    do
        local t = 1.0
        local x, y, z = obj.getvalue(target .. ".pos")
        local rx, ry, rz = obj.getvalue(target .. ".angle")
        local sx, sy, sz = obj.getvalue(target .. ".scale")

        if global[kKeyXform] ~= nil and obj.load("layer", target_layer, true) then
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

    local to = vector.translate({ 0.0, 0.0, 0.0 })

    local props = obj.getoption("camera_param")

    local d, up = vector.align(
        influence,
        { to[1] - props.x, to[2] - props.y, to[3] - props.z },
        track_axis,
        { props.tx - props.x, props.ty - props.y, props.tz - props.z },
        { props.ux, props.uy, props.uz }
    )

    props.ux, props.uy, props.uz = up[1], up[2], up[3]
    props.tx, props.ty, props.tz = d[1] + props.x, d[2] + props.y, d[3] + props.z

    obj.setoption("camera_param", props)
end
