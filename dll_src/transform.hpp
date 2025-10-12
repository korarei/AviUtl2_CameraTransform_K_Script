#pragma once

#include <vector>

#include "structs.hpp"
#include "vector_3d.hpp"

namespace Transform {
int
transform(const Param &param, const Parent &parent, const Cam &input, Cam &output) noexcept;

std::vector<Vec3<double>>
rotate(const std::vector<Vec3<double>> &input, const Rot &rot) noexcept;
}  // namespace Transform
