#include <iterator>

#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <module2.h>

#include "structs.hpp"
#include "transform.hpp"

#ifndef VERSION
#define VERSION L"0.1.0"
#endif

void
transform(SCRIPT_MODULE_PARAM *p) {
    auto n = p->get_param_num();
    if (n != 3) {
        p->set_error("Incorrect number of arguments");
        return;
    }
    constexpr int param_idx = 0;
    constexpr int parent_idx = 1;
    constexpr int input_idx = 2;

    auto to_num = [&](int idx, const char *key) { return p->get_param_table_double(idx, key); };
    auto to_int = [&](int idx, const char *key) { return p->get_param_table_int(idx, key); };

    Param param(to_num(param_idx, "x"), to_num(param_idx, "y"), to_num(param_idx, "z"),
                to_num(param_idx, "rw"), to_num(param_idx, "rx"), to_num(param_idx, "ry"),
                to_num(param_idx, "rz"), to_int(param_idx, "rot_mode"));

    Parent parent(to_int(parent_idx, "type"), to_num(parent_idx, "x"), to_num(parent_idx, "y"),
                  to_num(parent_idx, "z"), to_num(parent_idx, "rw"), to_num(parent_idx, "rx"),
                  to_num(parent_idx, "ry"), to_num(parent_idx, "rz"),
                  to_int(parent_idx, "rot_mode"), to_num(parent_idx, "scale"));

    Cam input(to_num(input_idx, "x"), to_num(input_idx, "y"), to_num(input_idx, "z"),
              to_num(input_idx, "tx"), to_num(input_idx, "ty"), to_num(input_idx, "tz"),
              to_num(input_idx, "ux"), to_num(input_idx, "uy"), to_num(input_idx, "uz"));

    Cam output{};

    if (Transform::transform(param, parent, input, output)) {
        p->set_error("Camera transformation failed.");
        return;
    }

    LPCSTR keys[] = {"x", "y", "z", "tx", "ty", "tz", "ux", "uy", "uz"};
    double vals[] = {output.pos.get_x(),    output.pos.get_y(),    output.pos.get_z(),
                     output.target.get_x(), output.target.get_y(), output.target.get_z(),
                     output.up.get_x(),     output.up.get_y(),     output.up.get_z()};

    p->push_result_table_double(keys, vals, std::size(keys));
}

void
rotate(SCRIPT_MODULE_PARAM *p) {}

static SCRIPT_MODULE_FUNCTION functions[] = {
        {L"transform", transform}, {L"rotate", rotate}, {nullptr}};

static SCRIPT_MODULE_TABLE script_module_table = {L"CameraTransform_K v" VERSION L" by Korarei",
                                                  functions};

extern "C" SCRIPT_MODULE_TABLE *
GetScriptModuleTable(void) {
    return &script_module_table;
}
