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
    --#include "../parent.lua"
    local parent = require("parent")
    local compose = parent.compose

    local vector = obj.module("${SCRIPT_NAME}")

    influence = influence * 0.01

    if layer_reference == 0 then
        target_layer = math.max(target_layer, 0)
    else
        target_layer = math.max(obj.layer + target_layer, 0)
    end

    if target_layer == 0 or target_layer == obj.layer then
        return
    end

    vector.reset()

    if not compose(target_layer) then
        return
    end

    local to = vector.translate({ 0.0, 0.0, 0.0 })

    do
        local camera = obj.getoption("camera_param")
        local focus = obj.getoption("camera_focus")

        local d, up = vector.align(
            influence,
            { to[1] - camera.x, to[2] - camera.y, to[3] - camera.z },
            track_axis,
            { camera.tx - camera.x, camera.ty - camera.y, camera.tz - camera.z },
            { camera.ux, camera.uy, camera.uz }
        )

        local tx, ty, tz = d[1] + camera.x, d[2] + camera.y, d[3] + camera.z

        camera.ux, camera.uy, camera.uz = up[1], up[2], up[3]
        camera.tx, camera.ty, camera.tz = tx, ty, tz

        focus.x, focus.y, focus.z = tx, ty, tz

        obj.setoption("camera_param", camera)
        obj.setoption("camera_focus", focus)
    end
end
