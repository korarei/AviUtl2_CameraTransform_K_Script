#pragma once

#include "structs.hpp"

namespace Transform {
int
transform(const Param &param, const Parent &parent, const Cam &input, Cam &output) noexcept;
}  // namespace Transform