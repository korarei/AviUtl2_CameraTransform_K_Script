#pragma once

#include "vector_3d.hpp"

using Vec3d = Vec3<double>;

struct Param {
    Vec3d pos;
    double rw;
    Vec3d rot;
    unsigned int rot_mode;

    constexpr Param(double x, double y, double z, double rw_, double rx, double ry, double rz,
                    int rot_mode_) noexcept :
        pos(x, y, z), rw(rw_), rot(rx, ry, rz), rot_mode(static_cast<unsigned int>(rot_mode_)) {}
};

struct Parent {
    int type;
    Param param;
    double scale;

    constexpr Parent(int type_, double x, double y, double z, double rw, double rx, double ry,
                     double rz, int mode, double scale_) noexcept :
        type(type_), param(x, y, z, rw, rx, ry, rz, mode), scale(scale_) {}
};

struct Cam {
    Vec3d pos;
    Vec3d target;
    Vec3d up;

    constexpr Cam() noexcept = default;

    constexpr Cam(double x, double y, double z, double tx, double ty, double tz, double ux,
                  double uy, double uz) noexcept :
        pos(x, y, z), target(tx, ty, tz), up(ux, uy, uz) {}

    constexpr Cam(const Vec3d &pos_, const Vec3d &target_, const Vec3d &up_) noexcept :
        pos(pos_), target(target_), up(up_) {}
};
