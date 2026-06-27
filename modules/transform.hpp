#pragma once

#include <windows.h>

#include <module2.h>

namespace transform {
void TryEnter(SCRIPT_MODULE_PARAM* param);
void Align(SCRIPT_MODULE_PARAM* param);
void Compose(SCRIPT_MODULE_PARAM* param);
void Transform(SCRIPT_MODULE_PARAM* param);
void Translate(SCRIPT_MODULE_PARAM* param);
void Rotate(SCRIPT_MODULE_PARAM* param);
void Reset(SCRIPT_MODULE_PARAM* param);
}  // namespace transform
