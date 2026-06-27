#include <windows.h>

#include <module2.h>

#include "transform.hpp"

#include "api.h"

#ifndef VERSION
#define VERSION L"0.1.0"
#endif

#ifndef REQUIRES_AVIUTL2
#define REQUIRES_AVIUTL2 2000100u
#endif

namespace {
constinit SCRIPT_MODULE_FUNCTION functions[] = {
    {L"tryenter", transform::TryEnter},   {L"align", transform::Align},
    {L"compose", transform::Compose},     {L"transform", transform::Transform},
    {L"translate", transform::Translate}, {L"rotate", transform::Rotate},
    {L"reset", transform::Reset},         {nullptr, nullptr},
};

constinit SCRIPT_MODULE_TABLE info = {
    .information = L"CameraTransform_K v" VERSION L" by Korarei",
    .functions = functions,
};
}  // namespace

extern "C" {
API DWORD RequiredVersion() { return REQUIRES_AVIUTL2; }

API bool InitializePlugin(DWORD version) { return version >= RequiredVersion(); }

API void UninitializePlugin() {}

API SCRIPT_MODULE_TABLE* GetScriptModuleTable() { return &info; }
}
