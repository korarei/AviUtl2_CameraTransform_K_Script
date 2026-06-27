--@Lens

--require:${PROJECT_REQUIRES_AVIUTL2}
--information:Lens@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}

local focal_length = 50.0 --track@focal_length:Focal Length,1,5000,50,0.01,0.00,0.01
local use_dolly_zoom = false --checksection@use_dolly_zoom:Dolly Zoom,false,false
--group:Sensor,false
local sensor_fit = 0 --select@sensor_fit:Sensor::Fit,Auto=0,Horizontal=1,Vertical=2
local sensor_size = 36.0 --track@sensor_size:Sensor::Size,1,100,36,0.01
--group:Depth of Field,false
local dof_focus_distance = 0.0 --track@dof_focus_distance:DOF::Focus Distance,0,100000,0,0.01,---

do
    local kEpsilon = 1.0e-4

    if (sensor_fit == 0 and obj.screen_w > obj.screen_h) or sensor_fit == 1 then
        sensor_size = sensor_size * obj.screen_h / obj.screen_w
    end

    local fov = 2.0 * math.atan(math.max(sensor_size, 1.0) / (2.0 * math.max(focal_length, 1.0)))

    local d = obj.screen_h / (2.0 * math.tan(fov * 0.5)) -- ExEdit の視野角焦点距離変換式

    local props = obj.getoption("camera_param")

    if dof_focus_distance > kEpsilon then
        local x, y, z = props.tx - props.x, props.ty - props.y, props.tz - props.z
        local norm = math.sqrt(x * x + y * y + z * z)

        if norm > kEpsilon then
            local scale = dof_focus_distance / norm
            props.tx, props.ty, props.tz = props.x + x * scale, props.y + y * scale, props.z + z * scale
        end
    end

    if use_dolly_zoom then
        local x, y, z = props.tx - props.x, props.ty - props.y, props.tz - props.z
        local norm = math.sqrt(x * x + y * y + z * z)

        if norm > kEpsilon then
            local scale = d / props.d
            props.x, props.y, props.z = props.tx - scale * x, props.ty - scale * y, props.tz - scale * z
        end
    end

    props.d = d

    obj.setoption("camera_param", props)
end
