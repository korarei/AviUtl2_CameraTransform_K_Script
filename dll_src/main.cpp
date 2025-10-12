#include <cstddef>
#include <iterator>
#include <string>

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
rotate(SCRIPT_MODULE_PARAM *p) {
    auto n = p->get_param_num();
    if (n < 2) {
        p->set_error("Incorrect number of arguments");
        return;
    }

    constexpr int rot_idx = 0;

    auto to_num = [&](int idx, const char *key) { return p->get_param_table_double(idx, key); };
    auto to_int = [&](int idx, const char *key) { return p->get_param_table_int(idx, key); };

    Rot rot(to_num(rot_idx, "rw"), to_num(rot_idx, "rx"), to_num(rot_idx, "ry"),
            to_num(rot_idx, "rz"), to_int(rot_idx, "rot_mode"));

    std::vector<Vec3d> input;
    for (int i = 1; i < n; ++i) input.emplace_back(to_num(i, "x"), to_num(i, "y"), to_num(i, "z"));

    auto output = Transform::rotate(input, rot);

    std::size_t count = output.size();
    std::size_t size = count * 3;
    std::vector<double> vals(size);
    std::vector<std::string> keys(size);
    std::vector<LPCSTR> ckeys(size);

    for (std::size_t i = 0; i < count; ++i) {
        std::size_t x = i * 3;
        std::size_t y = x + 1;
        std::size_t z = x + 2;
        std::string idx = std::to_string(i);

        vals[x] = output[i].get_x();
        vals[y] = output[i].get_y();
        vals[z] = output[i].get_z();

        keys[x] = "x" + idx;
        keys[y] = "y" + idx;
        keys[z] = "z" + idx;

        ckeys[x] = keys[x].c_str();
        ckeys[y] = keys[y].c_str();
        ckeys[z] = keys[z].c_str();
    }

    p->push_result_table_double(ckeys.data(), vals.data(), static_cast<int>(size));
}

static SCRIPT_MODULE_FUNCTION functions[] = {
        {L"transform", transform}, {L"rotate", rotate}, {nullptr}};

static SCRIPT_MODULE_TABLE script_module_table = {L"CameraTransform_K v" VERSION L" by Korarei",
                                                  functions};

extern "C" SCRIPT_MODULE_TABLE *
GetScriptModuleTable(void) {
    return &script_module_table;
}
