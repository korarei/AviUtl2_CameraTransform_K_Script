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
--separator:Aperture
local dof_aperture_f_stop = 0.0 --track@dof_aperture_f_stop:DOF::Aperture::F-Stop,0.0,128,0.0,0.01,---

do
    local kEpsilon = 1.0e-4

    focal_length = math.max(focal_length, 1.0)
    sensor_size = math.max(sensor_size, 1.0)

    if (sensor_fit == 0 and obj.screen_w > obj.screen_h) or sensor_fit == 1 then
        sensor_size = sensor_size * obj.screen_h / obj.screen_w
    end

    local fov = 2.0 * math.atan(sensor_size / (2.0 * focal_length))

    local d = obj.screen_h / (2.0 * math.tan(fov * 0.5)) -- ExEdit の視野角焦点距離変換式

    do
        local camera = obj.getoption("camera_param")
        local focus = obj.getoption("camera_focus")

        if dof_focus_distance > kEpsilon then
            local x, y, z = camera.tx - camera.x, camera.ty - camera.y, camera.tz - camera.z
            local norm = math.sqrt(x * x + y * y + z * z)

            if norm > kEpsilon then
                local scale = dof_focus_distance / norm
                camera.tx, camera.ty, camera.tz = camera.x + x * scale, camera.y + y * scale, camera.z + z * scale
            end
        end

        if use_dolly_zoom then
            local x, y, z = camera.tx - camera.x, camera.ty - camera.y, camera.tz - camera.z
            local norm = math.sqrt(x * x + y * y + z * z)

            if norm > kEpsilon then
                local scale = d / camera.d
                camera.x, camera.y, camera.z = camera.tx - scale * x, camera.ty - scale * y, camera.tz - scale * z
            end
        end

        if dof_aperture_f_stop > kEpsilon then
            local x, y, z = camera.tx - camera.x, camera.ty - camera.y, camera.tz - camera.z
            local norm = math.sqrt(x * x + y * y + z * z)

            if norm > kEpsilon then
                focus.bokeh = focal_length * d / (dof_aperture_f_stop * norm) * 0.5 -- それっぽいだけで保証はない
            end
        end

        camera.d = d

        focus.x, focus.y, focus.z = camera.tx, camera.ty, camera.tz

        obj.setoption("camera_param", camera)
        obj.setoption("camera_focus", focus)
    end
end
