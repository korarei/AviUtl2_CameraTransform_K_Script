local kKeyXform, compose

do
    local buffer = require("string.buffer")

    local vector = obj.module("CameraTransform_K")

    kKeyXform = "0e1ed7c9-af0e-4440-b903-eb36ba941ede"

    ---@param target integer
    ---@return boolean
    compose = function(target)
        local name = "layer" .. target

        if not obj.getvalue(name) then
            print("@warn", "Object not found on layer " .. target)
            vector.reset()
            return false
        end

        if not vector.tryenter(target) then
            print("@warn", "Cyclic reference is not allowed")
            vector.reset()
            return false
        end

        local t = 1.0
        local x, y, z = obj.getvalue(name .. ".pos")
        local rx, ry, rz = obj.getvalue(name .. ".angle")
        local sx, sy, sz = obj.getvalue(name .. ".scale")

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
        end

        vector.compose(t, x, y, z, 0.0, rx, ry, rz, 21, sx, sy, sz)

        return true
    end
end

if ... then
    return { kKeyXform = kKeyXform, compose = compose }
end
