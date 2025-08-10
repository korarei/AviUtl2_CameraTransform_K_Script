#pragma once

#include "vector_3d.hpp"

struct CParam {
    double x, y, z;
    double rw, rx, ry, rz;
    unsigned int rot_mode;
};

struct CParent {
    int type;
    double x, y, z;
    double rw, rx, ry, rz;
    unsigned int rot_mode;
    double scale;
};

struct CCam {
    double x, y, z;
    double tx, ty, tz;
    double ux, uy, uz;

    constexpr CCam(const Vec3<double> &pos, const Vec3<double> &target,
                   const Vec3<double> &up) noexcept :
        x(pos.get_x()),
        y(pos.get_y()),
        z(pos.get_z()),
        tx(target.get_x()),
        ty(target.get_y()),
        tz(target.get_z()),
        ux(up.get_x()),
        uy(up.get_y()),
        uz(up.get_z()) {}
};

struct Param {
    Vec3<double> pos;
    double rw;
    Vec3<double> rot;
    unsigned int rot_mode;

    constexpr Param(const CParam &c_param) noexcept :
        pos(c_param.x, c_param.y, c_param.z),
        rw(c_param.rw),
        rot(c_param.rx, c_param.ry, c_param.rz),
        rot_mode(c_param.rot_mode) {}

    constexpr Param(double x, double y, double z, double rw, double rx, double ry, double rz,
                    unsigned int mode) noexcept :
        pos(x, y, z), rw(rw), rot(rx, ry, rz), rot_mode(mode) {}
};

struct Parent {
    int type;
    Param param;
    double scale;

    constexpr Parent(const CParent &c_parent) noexcept :
        type(c_parent.type),
        param(c_parent.x, c_parent.y, c_parent.z, c_parent.rw, c_parent.rx, c_parent.ry,
              c_parent.rz, c_parent.rot_mode),
        scale(c_parent.scale) {}
};

struct Cam {
    Vec3<double> pos;
    Vec3<double> target;
    Vec3<double> up;

    constexpr Cam(const CCam &c_cam) noexcept :
        pos(c_cam.x, c_cam.y, c_cam.z),
        target(c_cam.tx, c_cam.ty, c_cam.tz),
        up(c_cam.ux, c_cam.uy, c_cam.uz) {}
};
