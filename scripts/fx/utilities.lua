local copyxform

do
    copyxform = function(dst, src)
        dst.ox, dst.oy, dst.oz = src.ox, src.oy, src.oz
        dst.cx, dst.cy, dst.cz = src.cx, src.cy, src.cz
        dst.rx, dst.ry, dst.rz = src.rx, src.ry, src.rz
        dst.sx, dst.sy, dst.sz = src.sx, src.sy, src.sz
        dst.alpha = src.alpha
    end
end

if ... then
    return { copyxform = copyxform }
end
