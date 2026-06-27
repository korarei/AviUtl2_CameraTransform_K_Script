local copyxform, stop

do
    ---@param dst table
    ---@param src table
    copyxform = function(dst, src)
        dst.ox, dst.oy, dst.oz = src.ox, src.oy, src.oz
        dst.cx, dst.cy, dst.cz = src.cx, src.cy, src.cz
        dst.rx, dst.ry, dst.rz = src.rx, src.ry, src.rz
        dst.sx, dst.sy, dst.sz = src.sx, src.sy, src.sz
        dst.alpha = src.alpha
    end

    ---@param e string
    stop = function(e)
        print("@error", e)
        obj.load("text", "")
    end
end

if ... then
    return { copyxform = copyxform, stop = stop }
end
