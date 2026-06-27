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
