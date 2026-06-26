#include "transform.hpp"

#include <Eigen/Core>
#include <algorithm>
#include <numbers>

#include <Eigen/Geometry>

namespace {
Eigen::Affine3d xform = Eigen::Affine3d::Identity();

[[nodiscard]] inline constexpr double ToRad(double deg) noexcept {
    constexpr double f = std::numbers::pi / 180.0;
    return deg * f;
}

[[nodiscard]] inline Eigen::Matrix3d ToRotationMatrix(int mode, const std::array<double, 3>& angle) {
    const std::array<int, 3> order{mode / 9, (mode / 3) % 3, mode % 3};
    const std::array<Eigen::Vector3d, 3> axis = {
        Eigen::Vector3d::UnitX(),
        Eigen::Vector3d::UnitY(),
        Eigen::Vector3d::UnitZ(),
    };

    return (Eigen::AngleAxisd(angle[order[2]], axis[order[2]]) * Eigen::AngleAxisd(angle[order[1]], axis[order[1]]) *
            Eigen::AngleAxisd(angle[order[0]], axis[order[0]]))
        .toRotationMatrix();
}
}  // namespace

namespace transform {
void Align(SCRIPT_MODULE_PARAM* param) {
    const auto n = param->get_param_num();

    if (n < 3) {
        param->set_error("Function call has wrong argument count");
        return;
    }

    if (n == 3) {
        return;
    }

    const auto t = std::clamp(param->get_param_double(0), 0.0, 1.0);

    Eigen::Vector3d to;

    if (param->get_param_array_num(1) == 3) {
        const auto x = param->get_param_array_double(1, 0);
        const auto y = param->get_param_array_double(1, 1);
        const auto z = param->get_param_array_double(1, 2);

        to = Eigen::Vector3d(x, y, z);
    } else {
        to = Eigen::Vector3d::UnitZ();
    }

    Eigen::Vector3d from;

    switch (param->get_param_int(2)) {
        case -3:
            from = -Eigen::Vector3d::UnitZ();
            break;
        case -2:
            from = -Eigen::Vector3d::UnitY();
            break;
        case -1:
            from = -Eigen::Vector3d::UnitX();
            break;
        case 1:
            from = Eigen::Vector3d::UnitX();
            break;
        case 2:
            from = Eigen::Vector3d::UnitY();
            break;
        case 3:
            from = Eigen::Vector3d::UnitZ();
            break;
        default:
            param->set_error("Unsupported axis");
            return;
    }

    const Eigen::Quaterniond q = Eigen::Quaterniond::Identity().slerp(t, Eigen::Quaterniond::FromTwoVectors(from, to));

    for (int i = 3; i < n; ++i) {
        Eigen::Vector3d v;

        if (param->get_param_array_num(i) == 3) {
            const auto x = param->get_param_array_double(i, 0);
            const auto y = param->get_param_array_double(i, 1);
            const auto z = param->get_param_array_double(i, 2);

            v = Eigen::Vector3d(x, y, z);
        } else {
            v = Eigen::Vector3d::Identity();
        }

        v = q * v;

        param->push_result_array_double(v.data(), 3);
    }
}

void Compose(SCRIPT_MODULE_PARAM* param) {
    if (param->get_param_num() != 12) {
        param->set_error("Function call has wrong argument count");
        return;
    }

    const auto t = std::clamp(param->get_param_double(0), 0.0, 1.0);

    const auto x = param->get_param_double(1) * t;
    const auto y = param->get_param_double(2) * t;
    const auto z = param->get_param_double(3) * t;
    const auto rw = param->get_param_double(4);
    const auto rx = param->get_param_double(5);
    const auto ry = param->get_param_double(6);
    const auto rz = param->get_param_double(7);
    const auto mode = param->get_param_int(8);
    const auto sx = param->get_param_double(9) * t;
    const auto sy = param->get_param_double(10) * t;
    const auto sz = param->get_param_double(11) * t;

    Eigen::Affine3d h = Eigen::Affine3d::Identity();
    h.translate(Eigen::Vector3d(x, y, z));
    h.scale(Eigen::Vector3d(sx, sy, sz));

    if (mode == 0) {
        h.rotate(Eigen::Quaterniond::Identity().slerp(t, Eigen::Quaterniond(rw, rx, ry, rz).normalized()));
    } else if (mode == 1) {
        h.rotate(Eigen::AngleAxisd(ToRad(rw * t), Eigen::Vector3d(rx, ry, rz).normalized()));
    } else if (mode >= 5 && mode <= 21) {
        h.rotate(ToRotationMatrix(mode, {ToRad(rx * t), ToRad(ry * t), ToRad(rz * t)}));
    } else {
        param->set_error("Unsupported rotation mode");
        return;
    }

    xform = xform * h;
}

void Transform(SCRIPT_MODULE_PARAM* param) {
    const auto n = param->get_param_num();

    if (n == 0) {
        return;
    }

    for (int i = 0; i < n; ++i) {
        Eigen::Vector3d v;

        if (param->get_param_array_num(i) == 3) {
            const auto x = param->get_param_array_double(i, 0);
            const auto y = param->get_param_array_double(i, 1);
            const auto z = param->get_param_array_double(i, 2);

            v = Eigen::Vector3d(x, y, z);
        } else {
            v = Eigen::Vector3d::Identity();
        }

        v = xform * v;

        param->push_result_array_double(v.data(), 3);
    }
}

void Translate(SCRIPT_MODULE_PARAM* param) {
    const auto n = param->get_param_num();

    if (n == 0) {
        return;
    }

    for (int i = 0; i < n; ++i) {
        Eigen::Vector3d v;

        if (param->get_param_array_num(i) == 3) {
            const auto x = param->get_param_array_double(i, 0);
            const auto y = param->get_param_array_double(i, 1);
            const auto z = param->get_param_array_double(i, 2);

            v = Eigen::Vector3d(x, y, z);
        } else {
            v = Eigen::Vector3d::Identity();
        }

        v = xform.translation() + v;

        param->push_result_array_double(v.data(), 3);
    }
}

void Rotate(SCRIPT_MODULE_PARAM* param) {
    const auto n = param->get_param_num();

    if (n == 0) {
        return;
    }

    for (int i = 0; i < n; ++i) {
        Eigen::Vector3d v;

        if (param->get_param_array_num(i) == 3) {
            const auto x = param->get_param_array_double(i, 0);
            const auto y = param->get_param_array_double(i, 1);
            const auto z = param->get_param_array_double(i, 2);

            v = Eigen::Vector3d(x, y, z);
        } else {
            v = Eigen::Vector3d::Identity();
        }

        v = xform.rotation() * v;

        param->push_result_array_double(v.data(), 3);
    }
}

void Reset([[maybe_unused]] SCRIPT_MODULE_PARAM* param) { xform = Eigen::Affine3d::Identity(); }
}  // namespace transform
