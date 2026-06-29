local kKeyXform, compose

do
    local buffer = require("string.buffer")

    local vector = obj.module("CameraTransform_K")

    kKeyXform = "0e1ed7c9-af0e-4440-b903-eb36ba941ede"

    ---@param target integer
    ---@return boolean
    compose = function(target)
        local tonumber, comp, getvalue = tonumber, vector.compose, obj.getvalue

        local name = "layer" .. target
        local has_empty = getvalue(target, "Empty@CameraTransform_K", "Influence") ~= nil

        if not getvalue(name) then
            print("@warn", "Object not found on layer " .. target)
            vector.reset()
            return false
        end

        if not has_empty then
            vector.reset()
        end

        vector.tryenter(obj.layer)

        if not vector.tryenter(target) then
            print("@warn", "Cyclic reference is not allowed")
            vector.reset()
            return false
        end

        local t = 1.0
        local x, y, z = getvalue(name .. ".pos")
        local rx, ry, rz = getvalue(name .. ".angle")
        local sx, sy, sz = getvalue(name .. ".scale")

        if has_empty then
            global[kKeyXform] = nil

            if obj.load("layer", target, true) and global[kKeyXform] ~= nil then
                local xform = buffer.decode(global[kKeyXform])

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
            else
                vector.reset()
            end
        end

        do
            local empties = {}

            do
                local curr = target

                for i = target - 1, 1, -1 do
                    local range = getvalue(i, "グループ制御", "対象レイヤー数")

                    if range ~= nil then
                        range = tonumber(range) or 0
                        if range == 0 or range >= curr - i then
                            empties[#empties + 1] = i
                            curr = i
                        end
                    end
                end
            end

            for i = #empties, 1, -1 do
                local j = empties[i]

                local scale = getvalue(j, "グループ制御", "拡大率") * 0.01

                comp(
                    t,
                    getvalue(j, "グループ制御", "X"),
                    getvalue(j, "グループ制御", "Y"),
                    getvalue(j, "グループ制御", "Z"),
                    0.0,
                    getvalue(j, "グループ制御", "X軸回転"),
                    getvalue(j, "グループ制御", "Y軸回転"),
                    getvalue(j, "グループ制御", "Z軸回転"),
                    21,
                    scale,
                    scale,
                    scale
                )
            end
        end

        comp(t, x, y, z, 0.0, rx, ry, rz, 21, sx, sy, sz)

        return true
    end
end

if ... then
    return { kKeyXform = kKeyXform, compose = compose }
end
