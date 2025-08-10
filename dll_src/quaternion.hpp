#pragma once

#include <cmath>

#include "vector_3d.hpp"

class Quaternion {
public:
    // Constructors.
    constexpr Quaternion() noexcept : w(1.0), v(Vec3<double>()) {}
    constexpr Quaternion(double w, const Vec3<double> &v) noexcept : w(w), v(v) {}
    constexpr Quaternion(double w, double x, double y, double z) noexcept : w(w), v(x, y, z) {}

    // Getters.
    [[nodiscard]] constexpr double get_w() const noexcept { return w; }
    [[nodiscard]] constexpr const Vec3<double> &get_v() const noexcept { return v; }

    // Setters.
    constexpr void set_w(double new_w) noexcept { w = new_w; }
    constexpr void set_v(const Vec3<double> &new_v) noexcept { v = new_v; }

    // Arithmetic operators.
    [[nodiscard]] constexpr Quaternion operator*(const Quaternion &other) const noexcept {
        return Quaternion(w * other.w - v.dot(other.v),
                          w * other.v + other.w * v + v.cross(other.v));
    }

    // Normalization.
    [[nodiscard]] Quaternion normalize() const noexcept {
        const double norm = std::sqrt(w * w + v.dot(v));
        if (Vec3<double>::is_zero(norm))
            return Quaternion();

        return Quaternion(w / norm, v / norm);
    }

    // Conjugate.
    [[nodiscard]] constexpr Quaternion conjugate() const noexcept { return Quaternion(w, -v); }

private:
    double w;
    Vec3<double> v;
};
