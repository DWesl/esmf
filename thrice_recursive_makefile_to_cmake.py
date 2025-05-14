#!/usr/bin/env python3
import glob
import os.path
import sys
from collections import defaultdict
import textwrap

DIRS_TO_PROCESS = ["src/"]


def test_base_name_from_build_name(test_name: str) -> str:
    return (
        test_name.removeprefix("ESMF_")
        .removeprefix("ESMC_")
        .removeprefix("ESMCI_")
        .removesuffix("UTest")
    )


def process_directory(directory: str):
    if os.path.basename(os.path.dirname(directory)) == "Legacy":
        print("Skipping nonexistent directory", directory)
        return
    if os.path.basename(directory) in ("ESMX", "PIO"):
        print("Skipping project with functional CMake build", directory)
        return
    if os.path.basename(directory) == "acc":
        print("Skipping handwritten directory", directory)
        return
    if os.path.basename(directory) == "src" and os.path.basename(os.path.dirname(directory)) == "Mesh":
        print("Skipping handwritten directory")
        return
    print("Processing directory", directory)
    dependency_graph = defaultdict(set)
    target_commands = defaultdict(list)
    variables = defaultdict(list)
    count = 0
    with open(os.path.join(directory, "makefile"), "r") as in_file:
        last_line = None
        last_target = ""
        for line in in_file:
            # print("Line", line)
            count += 1
            line = line.rstrip("\n")
            if last_line is not None:
                new_line = line
                if ":" in last_line:
                    if len(new_line) == 0 or new_line.isspace():
                        pass
                    elif new_line[0].isspace() and new_line.strip():
                        last_line = "\n".join([last_line, new_line])
                        continue
                line = last_line + new_line
            if line.endswith("\\"):
                last_line = line[:-1]
                continue
            else:
                last_line = None
            if "#" in line:
                line, comment = line.split("#", 1)
            if len(line) == 0 or line.isspace():
                last_line = None
                last_target = ""
                continue
            # print("Processing line", line)
            if ":" in line:
                lines = line.split("\n", 1)
                depline = lines[0]
                commands = lines[1:]
                target, deps = depline.split(":", 1)
                target = target.strip()
                dependency_graph[target].update(deps.split())
                target_commands[target].extend(commands)
                last_target = target
                # last_line = line
            elif "=" in line:
                if "+=" in line:
                    var, value = line.split("+=", 1)
                else:
                    var, value = line.split("=", 1)
                variables[var.strip()].extend(value.strip().split())
            elif line[0].isspace() and last_target:
                target_commands[last_target].extend(line.strip())
    # print("Read makefile,", count, "lines")
    # print(variables)
    if variables["LIBBASE"]:
        libbase = variables["LIBBASE"][0]
        libname = libbase.removeprefix("lib")

    with open(os.path.join(directory, "CMakeLists.txt"), "w") as out_file:

        def out_file_write(to_write: str):
            out_file.write(textwrap.dedent(to_write))

        include_dir = os.path.join(directory, "include")
        if os.path.isdir(include_dir):
            out_file_write(
                f'\ntarget_include_directories(esmf PRIVATE ${{ESMF_SOURCE_DIR}}/{include_dir:s})\n'
            )
        # include_dir = os.path.join(directory, "..", "include")
        # if os.path.isdir(include_dir):
        #     out_file_write(
        #         f'\ntarget_include_directories(esmf PRIVATE ${{ESMF_SOURCE_DIR}}/{include_dir:s})\n'
        #     )
        out_file_write(
            R"""
            if(${Git_FOUND})
                set(ESMF_VERSION_STRING_GIT ${GIT_VERSION_STRING})
                add_compile_definitions(ESMF_VERSION_STRING_GIT="${ESMF_VERSION_STRING_GIT}")
            endif()
            """
        )
        if variables["ESMF_CXXCOMPILECPPFLAGS"]:
            cxx_defines = []
            cxx_options = []
            cxx_incdirs = []
            for option in variables["ESMF_CXXCOMPILECPPFLAGS"]:
                if option.startswith("-D"):
                    cxx_defines.append(option[2:])
                elif option.startswith("-I"):
                    cxx_incdirs.append(
                        option[2:]
                        .replace("$(ESMF_DIR)", "${ESMF_SOURCE_DIR}")
                        .replace("$(LOCDIR)", directory)
                    )
                else:
                    cxx_options.append(option)
            if cxx_options:
                out_file_write(
                    f"target_compile_options(esmf PRIVATE {' '.join(cxx_options):s})\n"
                )
            if cxx_defines:
                out_file_write(
                    f"target_compile_definitions(esmf PRIVATE {' '.join(cxx_defines):s})\n"
                )
            if cxx_incdirs:
                out_file_write(
                    f"target_include_directories(esmf PRIVATE {' '.join(cxx_incdirs):s})\n"
                )

        for subdir in set(variables["DIRS"]):
            DIRS_TO_PROCESS.append(os.path.join(directory, subdir))
            if subdir == "Mapper":
                out_file_write(
                    f"""\
                    if(ESMF_MAPPER_BUILD)
                      add_subdirectory({subdir:s})
                    endif()
                """
                )
            elif subdir == "Moab":
                out_file_write(
                    f"""\
                    if(ESMF_MOAB)
                      add_subdirectory({subdir:s})
                    endif()
                """
                )
            elif subdir in ("Lapack", "BLAS"):
                out_file_write(
                    f"""\
                    if(ESMF_LAPACK STREQUAL internal)
                      add_subdirectory({subdir:s})
                    endif()
                    """
                )
            elif subdir == "yaml-cpp":
                out_file_write(f"""\
                if(ESMF_YAMLCPP STREQUAL internal)
                  add_subdirectory({subdir:s})
                endif()
                """)
            else:
                out_file_write(f"add_subdirectory({subdir:s})\n")
        existing_test_executables = set()
        for test in variables["TESTS_BUILD"]:
            build_name = os.path.basename(test)
            if build_name not in existing_test_executables:
                existing_test_executables.add(build_name)
                base_name = test_base_name_from_build_name(build_name)
                objects = {f"{build_name:s}.o"}
                objects.update(variables[f"ESMF_UTEST_{base_name:s}_OBJS"])
                sources = []
                for obj in objects:
                    sources.extend(
                        [
                            os.path.basename(src).replace(".cppF90", ".F90")
                            for src in glob.glob(
                                os.path.join(directory, os.path.splitext(obj)[0] + ".*")
                            )
                        ]
                    )
                # print("Building test", build_name, "sources", sources)
                if not sources:
                    raise SystemExit(f"Failed to find sources for objects {objects}")
                out_file_write(
                    f"""add_executable({build_name:s}  {" ".join(sources):s})\n"""
                )
                sourceext = {os.path.splitext(src)[1] for src in sources}
                out_file_write(f"target_link_libraries({build_name:s} esmf)\n")
                out_file_write("if(ESMF_OPENMP)\n")
                if ".f90" in sourceext or ".F90" in sourceext:
                    out_file_write(
                        f"  target_link_libraries({build_name:s} OpenMP::OpenMP_Fortran)\n"
                    )
                if (
                    ".C" in sourceext
                    or ".cxx" in sourceext
                    or ".cpp" in sourceext
                    or ".cc" in sourceext
                ):
                    out_file_write(
                        f"  target_link_libraries({build_name:s} OpenMP::OpenMP_CXX)\n"
                    )
                if ".c" in sourceext:
                    out_file_write(
                        f"  target_link_libraries({build_name:s} OpenMP::OpenMP_C)\n"
                    )
                out_file_write("endif()\n")

        for test in variables["TESTS_RUN"]:
            build_name = test[4:]
            base_name = test_base_name_from_build_name(build_name)
            if target_commands[test]:
                labels = " ".join(
                    label for label in target_commands[test][0].split()[1:]
                )
            else:
                labels = ""
            out_file_write(
                f"""\
            add_test({test:s} COMMAND {build_name:s})
            set_property(TEST {test:s} PROPERTY LABEL MPI {labels:s})
            """
            )
        for test in variables["TESTS_RUN_UNI"]:
            build_name = test[4:-3]
            base_name = test_base_name_from_build_name(build_name)
            if target_commands[test]:
                labels = " ".join(
                    label for label in target_commands[test][0].split()[1:]
                )
            else:
                labels = ""
            out_file_write(
                f"""\
            add_test({test:s} COMMAND {build_name:s})
            set_property(TEST {test:s} PROPERTY LABEL serial {labels:s})
            """
            )
        if variables["AUTOGEN"]:
            for gen_file in variables["AUTOGEN"]:
                source_file = gen_file.replace(".F90", ".cppF90")
                out_file_write(
                    f"""\
                    add_custom_command(OUTPUT {gen_file:s}
                        MAIN_DEPENDENCY {source_file:s}
                        VERBATIM
                        COMMAND ${{ESMF_BINARY_DIR}}/cppF90_to_F90 ${{ESMF_SOURCE_DIR}}/{source_file:s} ${{ESMF_BINARY_DIR}}/{gen_file:s})
                    """
                )
            out_file_write(f'set(AUTOGEN {" ".join(variables["AUTOGEN"]):s})\n')
        if variables["SOURCEC"]:
            out_file_write(
                f'target_sources({libname:s} PRIVATE {" ".join(variables["SOURCEC"]):s})\n'
            )
        if variables["SOURCEF"]:
            sources = []
            for src in variables["SOURCEF"]:
                if src == "$(AUTOGEN)":
                    sources.append("${AUTOGEN}")
                else:
                    sources.append(src)
            out_file_write(
                f'target_sources({libname:s} PRIVATE {" ".join(sources):s})\n'
            )
        if variables["SOURCEH"]:
            headers = []
            for hdr in variables["SOURCEH"]:
                if os.path.exists(os.path.join(directory, hdr)):
                    headers.append(hdr)
                elif os.path.exists(os.path.join(directory, "..", "include", hdr)):
                    headers.append(os.path.join("..", "include", hdr))
                else:
                    raise SystemExit(f"Can't find header {hdr:s}")
            out_file_write(
                f'target_sources({libname:s} PRIVATE {" ".join(headers):s})\n'
            )
        if variables["STOREH"]:
            headers = []
            for hdr in variables["STOREH"]:
                if os.path.exists(os.path.join(directory, hdr)):
                    headers.append(hdr)
                elif os.path.exists(os.path.join(directory, "..", "include", hdr)):
                    headers.append(os.path.join("..", "include", hdr))
                else:
                    raise SystemExit(f"Can't find header {hdr:s}")
            out_file_write(
                f'target_sources({libname:s} PUBLIC {" ".join(headers):s})\n'
            )
        if variables["APPS_BUILD"]:
            app_names = variables["APPS_BUILD"]
            assert len(app_names) == 1
            app_name = os.path.basename(app_names[0])
            # print("Creating app", app_name, "using language", variables["APPS_MAINLANGUAGE"])
            if variables["APPS_MAINLANGUAGE"] == ["script"]:
                # print("Script, install-only")
                out_file_write(
                    f"""\
                install(FILES {" ".join(variables["APPS_OBJ"]):s} TYPE BIN)
                """
                )
            else:
                # print("Executable, more work", variables["APPS_OBJ"])
                sources = {
                    os.path.basename(src)
                    for obj in variables["APPS_OBJ"]
                    for src in glob.glob(
                        f"{os.path.join(directory, os.path.splitext(obj)[0]):s}.*"
                    )
                    if not src.endswith(".o")
                }
                # print(sources)
                out_file_write(
                    f"""\
                add_executable({app_name:s}  {" ".join(sources):s})
                install(TARGETS {app_name:s})
                """
                )
            if variables["APPS_MAINLANGUAGE"] == "scripts":
                raise SystemExit("Checkpoint")


count = 0
while len(DIRS_TO_PROCESS) > 0:
    # print(DIRS_TO_PROCESS)
    process_directory(DIRS_TO_PROCESS.pop())
    # count += 1
    # if count > 10:
    #     print(DIRS_TO_PROCESS)
    #     break
