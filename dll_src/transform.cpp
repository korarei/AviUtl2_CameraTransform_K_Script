#include "transform.hpp"

#include <array>
#define _USE_MATH_DEFINES
#include <cmath>
#include <cstdint>

#include "quaternion.hpp"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

using Vec3d = Vec3<double>;
using Mat3d = Mat3<double>;

[[nodiscard]] inline static constexpr double
to_rad(double deg) noexcept {
    return deg * (M_PI / 180.0);
}

[[nodiscard]] inline static constexpr std::array<unsigned int, 3>
decode_ord(unsigned int mode) noexcept {
    unsigned int ax_2 = mode / 9;
    unsigned int ax_1 = (mode / 3) % 3;
    unsigned int ax_0 = mode % 3;
    return {ax_2, ax_1, ax_0};
}

[[nodiscard]] inline static constexpr Mat3d
make_rm(const Rot &rot) noexcept {
    const auto ord = decode_ord(rot.rot_mode);
    return Mat3d::rotation(to_rad(rot.xyz[ord[2]]), 1.0, ord[2])
         * Mat3d::rotation(to_rad(rot.xyz[ord[1]]), 1.0, ord[1])
         * Mat3d::rotation(to_rad(rot.xyz[ord[0]]), 1.0, ord[0]);
}

std::vector<Vec3d>
Transform::rotate(const std::vector<Vec3d> &input, const Rot &rot) noexcept {
    std::vector<Vec3d> output;
    output.reserve(input.size());

    if (rot.rot_mode == 0) {
        const auto q = Quaternion(rot.w, rot.xyz).normalize();
        const auto q_inv = q.conjugate();

        for (const auto &v : input) {
            const auto p = Quaternion(0.0, v);
            const auto p_rotated = q * p * q_inv;
            output.emplace_back(p_rotated.get_v());
        }

        return output;
    } else if (rot.rot_mode == 1) {
        const double t = to_rad(rot.w);
        const double cos = std::cos(t);
        const double sin = std::sin(t);
        const auto n = rot.xyz.normalize();

        for (const auto &v : input)
            output.emplace_back(cos * v + sin * n.cross(v) + (1.0 - cos) * n.dot(v) * n);

        return output;
    } else if (rot.rot_mode >= 5 && rot.rot_mode <= 21) {
        const auto rm = make_rm(rot);
        for (const auto &v : input) output.emplace_back(rm * v);

        return output;
    } else {
        return input;
    }
}

int
Transform::transform(const Param &param, const Parent &parent, const Cam &input,
                     Cam &output) noexcept {
    Vec3d g_pos, g_target, g_up;

    const auto l_pose = rotate({input.target - input.pos, input.up}, param.rot);
    const auto l_pos = param.pos + input.pos;

    switch (parent.type) {
        case 0: {
            g_pos = l_pos;
            g_target = g_pos + l_pose[0];
            g_up = l_pose[1];
            break;
        }
        case 1: {
            const auto g_pose = rotate({l_pos, l_pose[0], l_pose[1]}, parent.param.rot);
            g_pos = parent.param.pos + g_pose[0] * parent.scale;
            g_target = g_pos + g_pose[1];
            g_up = g_pose[2];
            break;
        }
        default:
            return 1;
    }

    output.pos = g_pos;
    output.target = g_target;
    output.up = g_up;
    return 0;
}
