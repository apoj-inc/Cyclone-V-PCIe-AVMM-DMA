#!/usr/bin/env python3
import os

paths_list = ["."]
submodule_suffix = "submodules/lists/buildable_submodules.lst"

paths_list_len = 0
path_id = 0

while len(paths_list) != paths_list_len:
    paths_list_len = len(paths_list)

    while path_id < paths_list_len:
        submodules = []

        filepath = f"{paths_list[path_id]}/{submodule_suffix}"
        
        if os.path.isfile(filepath):
            with open(filepath, "r") as f:
                submodules = f.read().splitlines()
        
        paths_list += submodules

        path_id += 1

lst_suffixes = ["rtl/lists/files_hex.lst",
                "rtl/lists/files_rtl.lst",
                "rtl/lists/incdirs.lst",
                "fpga/quartus/qsys/lists/names_qsys.lst",
                "fpga/quartus/custom_ip/lists/ip_paths.lst"]

full_lsts = [[] for _ in range(len(lst_suffixes))]

lst_names = ["files_hex.lst",
             "files_rtl.lst",
             "incdirs.lst",
             "names_qsys.lst",
             "ip_paths.lst"]

for path in paths_list:
    for i, lst_suffix in enumerate(lst_suffixes):
        filepath = f"{path}/{lst_suffix}"

        if not os.path.isfile(filepath):
            continue

        with open(f"{path}/{lst_suffix}", "r") as f:
            current_lst = f.read().splitlines()
            for j in range(len(current_lst)):
                current_lst[j] = f"{path}/{current_lst[j]}"
            full_lsts[i] += current_lst

os.makedirs(".cache/lists/", exist_ok=True)
for i, lst in enumerate(full_lsts[::-1]):
    with open(f".cache/lists/{lst_names[i]}", "w") as f:
        f.write('\n'.join(full_lsts[i]))