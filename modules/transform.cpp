#include "transform.hpp"

#include <Eigen/Core>
#include <numbers>

#include <Eigen/Geometry>

namespace {
Eigen::Affine3d affine = Eigen::Affine3d::Identity();

struct TransformProperty {
    struct Position {
        double x = 0.0, y = 0.0, z = 0.0;
    } position{};

    struct Rotation {
        double w = 0.0, x = 0.0, y = 0.0, z = 0.0;
        int mode = 21;
    } rotation{};

    struct Scale {
        double x = 1.0, y = 1.0, z = 1.0;
    } scale{};
};

[[nodiscard]] inline constexpr double ToDeg(double rad) noexcept {
    constexpr double f = 180.0 / std::numbers::pi;
    return rad * f;
}

[[nodiscard]] inline constexpr double ToRad(double deg) noexcept {
    constexpr double f = std::numbers::pi / 180.0;
    return deg * f;
}

[[nodiscard]] Eigen::Affine3d ToAffine(double t, const TransformProperty& xform) {
    static const std::array<Eigen::Vector3d, 3> axis{
        Eigen::Vector3d::UnitX(),
        Eigen::Vector3d::UnitY(),
        Eigen::Vector3d::UnitZ(),
    };

    Eigen::Affine3d h = Eigen::Affine3d::Identity();

    h.translate(Eigen::Vector3d(xform.position.x * t, xform.position.y * t, xform.position.z * t));

    if (xform.rotation.mode == 0) {
        Eigen::Quaterniond q(xform.rotation.w, xform.rotation.x, xform.rotation.y, xform.rotation.z);

        if (q.squaredNorm() < Eigen::NumTraits<double>::dummy_precision()) {
            q = Eigen::Quaterniond::Identity();
        } else {
            q.normalize();
        }

        h.rotate(Eigen::Quaterniond::Identity().slerp(t, q));
    } else if (xform.rotation.mode == 1) {
        Eigen::Vector3d v(xform.rotation.x, xform.rotation.y, xform.rotation.z);

        if (v.squaredNorm() < Eigen::NumTraits<double>::dummy_precision()) {
            v = Eigen::Vector3d::UnitZ();
        } else {
            v.normalize();
        }

        h.rotate(Eigen::AngleAxisd(ToRad(xform.rotation.w), v));
    } else if (xform.rotation.mode >= 5 && xform.rotation.mode <= 21) {
        const std::array<int, 3> order{xform.rotation.mode / 9, (xform.rotation.mode / 3) % 3, xform.rotation.mode % 3};
        const std::array<double, 3> angle{ToRad(xform.rotation.x), ToRad(xform.rotation.y), ToRad(xform.rotation.z)};

        const auto aa = [&](int i) { return Eigen::AngleAxisd(angle[i], axis[i]); };

        h.rotate((aa(order[2]) * aa(order[1]) * aa(order[0])).toRotationMatrix());
    } else {
        h.rotate(Eigen::Quaterniond::Identity());
    }

    h.scale(Eigen::Vector3d(xform.scale.x * t, xform.scale.y * t, xform.scale.z * t));

    return h;
}
}  // namespace

namespace transform {
void Align(SCRIPT_MODULE_PARAM* param) {
    const auto n = param->get_param_num();

    if (n < 3) {
        param->set_error("'align' expected at least 3 arguments");
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
            v = Eigen::Vector3d::Zero();
        }

        v = q * v;

        param->push_result_array_double(v.data(), 3);
    }
}

void Compose(SCRIPT_MODULE_PARAM* param) {
    if (param->get_param_num() != 12) {
        param->set_error("'compose' expects exactly 12 arguments");
        return;
    }

    const auto t = std::clamp(param->get_param_double(0), 0.0, 1.0);

    const TransformProperty xform{
        .position =
            {
                .x = param->get_param_double(1),
                .y = param->get_param_double(2),
                .z = param->get_param_double(3),
            },
        .rotation =
            {
                .w = param->get_param_double(4),
                .x = param->get_param_double(5),
                .y = param->get_param_double(6),
                .z = param->get_param_double(7),
                .mode = param->get_param_int(8),
            },
        .scale =
            {
                .x = param->get_param_double(9),
                .y = param->get_param_double(10),
                .z = param->get_param_double(11),
            },
    };

    affine = affine * ToAffine(t, xform);
}

void Transform(SCRIPT_MODULE_PARAM* param) {
    const auto n = param->get_param_num();

    if (n == 0) {
        return;
    }

    for (int i = 0; i < n; ++i) {
        const auto size = param->get_param_array_num(i);

        if (size == 12) {
            const auto t = std::clamp(param->get_param_array_double(i, 0), 0.0, 1.0);

            const TransformProperty xform{
                .position =
                    {
                        .x = param->get_param_array_double(i, 1),
                        .y = param->get_param_array_double(i, 2),
                        .z = param->get_param_array_double(i, 3),
                    },
                .rotation =
                    {
                        .w = param->get_param_array_double(i, 4),
                        .x = param->get_param_array_double(i, 5),
                        .y = param->get_param_array_double(i, 6),
                        .z = param->get_param_array_double(i, 7),
                        .mode = param->get_param_array_int(i, 8),
                    },
                .scale =
                    {
                        .x = param->get_param_array_double(i, 9),
                        .y = param->get_param_array_double(i, 10),
                        .z = param->get_param_array_double(i, 11),
                    },
            };

            const Eigen::Affine3d h = affine * ToAffine(t, xform);

            Eigen::Matrix3d rot, scale;
            h.computeRotationScaling(&rot, &scale);

            const Eigen::Vector3d pos = h.translation();

            double result[11];

            result[0] = pos.x(), result[1] = pos.y(), result[2] = pos.z();
            result[8] = scale(0, 0), result[9] = scale(1, 1), result[10] = scale(2, 2);

            result[7] = static_cast<double>(xform.rotation.mode);

            if (xform.rotation.mode == 0) {
                const Eigen::Quaterniond q(rot);

                result[3] = q.w(), result[4] = q.x(), result[5] = q.y(), result[6] = q.z();
            } else if (xform.rotation.mode == 1) {
                const Eigen::AngleAxisd aa(rot);
                const Eigen::Vector3d axis = aa.axis();

                result[3] = ToDeg(aa.angle()), result[4] = axis.x(), result[5] = axis.y(), result[6] = axis.z();
            } else if (xform.rotation.mode >= 5 && xform.rotation.mode <= 21) {
                const std::array<int, 3> order{
                    xform.rotation.mode / 9,
                    (xform.rotation.mode / 3) % 3,
                    xform.rotation.mode % 3,
                };

                const Eigen::Vector3d euler = rot.canonicalEulerAngles(order[2], order[1], order[0]);

                result[3] = 0.0;
                result[4] = ToDeg(euler.x()), result[5] = ToDeg(euler.y()), result[6] = ToDeg(euler.z());
            } else {
                result[3] = 0.0, result[4] = 0.0, result[5] = 0.0, result[6] = 0.0;
            }

            param->push_result_array_double(result, 11);

            continue;
        }

        Eigen::Vector3d v;

        if (size == 3) {
            const auto x = param->get_param_array_double(i, 0);
            const auto y = param->get_param_array_double(i, 1);
            const auto z = param->get_param_array_double(i, 2);

            v = Eigen::Vector3d(x, y, z);
        } else {
            v = Eigen::Vector3d::Zero();
        }

        v = affine * v;

        param->push_result_array_double(v.data(), 3);
    }
}

void Translate(SCRIPT_MODULE_PARAM* param) {
    const auto n = param->get_param_num();

    if (n == 0) {
        return;
    }

    const Eigen::Vector3d translation = affine.translation();

    for (int i = 0; i < n; ++i) {
        Eigen::Vector3d v;

        if (param->get_param_array_num(i) == 3) {
            const auto x = param->get_param_array_double(i, 0);
            const auto y = param->get_param_array_double(i, 1);
            const auto z = param->get_param_array_double(i, 2);

            v = Eigen::Vector3d(x, y, z);
        } else {
            v = Eigen::Vector3d::Zero();
        }

        v = translation + v;

        param->push_result_array_double(v.data(), 3);
    }
}

void Rotate(SCRIPT_MODULE_PARAM* param) {
    const auto n = param->get_param_num();

    if (n == 0) {
        return;
    }

    Eigen::Matrix3d rotation;
    affine.computeRotationScaling(&rotation, static_cast<Eigen::Matrix3d*>(nullptr));

    for (int i = 0; i < n; ++i) {
        Eigen::Vector3d v;

        if (param->get_param_array_num(i) == 3) {
            const auto x = param->get_param_array_double(i, 0);
            const auto y = param->get_param_array_double(i, 1);
            const auto z = param->get_param_array_double(i, 2);

            v = Eigen::Vector3d(x, y, z);
        } else {
            v = Eigen::Vector3d::Zero();
        }

        v = rotation * v;

        param->push_result_array_double(v.data(), 3);
    }
}

void Reset([[maybe_unused]] SCRIPT_MODULE_PARAM* param) { affine = Eigen::Affine3d::Identity(); }
}  // namespace transform
