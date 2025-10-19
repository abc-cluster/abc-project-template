# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# C Package Development Automation
# Tools for creating, testing, and building C research libraries

# Create a new C library package
create-c-package name description="Research C library":
    #!/usr/bin/env bash
    package_dir="c/{{name}}"
    mkdir -p "${package_dir}/src"
    mkdir -p "${package_dir}/tests"
    
    # Create CMakeLists.txt for build configuration
    cat <<EOF > "${package_dir}/CMakeLists.txt"
cmake_minimum_required(VERSION 3.10)
project({{name}} LANGUAGES C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

add_library({{name}} SHARED src/{{name}}.c)

enable_testing()
add_subdirectory(tests)
EOF

    # Create basic C source file
    cat <<EOF > "${package_dir}/src/{{name}}.c"
#include <stdio.h>
#include "{{name}}.h"

void hello() {
    printf("Hello from {{name}}!\n");
}
EOF

    # Create header file
    cat <<EOF > "${package_dir}/src/{{name}}.h"
#ifndef {{name}}_H
#define {{name}}_H

void hello();

#endif
EOF

    # Create test directory with CMakeLists.txt
    cat <<EOF > "${package_dir}/tests/CMakeLists.txt"
add_executable(test_{{name}} test_{{name}}.c)
target_link_libraries(test_{{name}} PRIVATE {{name}})
add_test(NAME test_{{name}} COMMAND test_{{name}})
EOF

    # Create a basic test file
    cat <<EOF > "${package_dir}/tests/test_{{name}}.c"
#include <assert.h>
#include "../src/{{name}}.h"

int main() {
    hello();
    // Perform more tests here
    return 0;
}
EOF

    echo "📦 Created C library: ${package_dir}"
    echo "📝 To build and test:"
    echo "   mkdir build"
    echo "   cd build"
    echo "   cmake .."
    echo "   cmake --build ."
    echo "   ctest"

# Test a C package
test-c package:
    #!/usr/bin/env bash
    if [ -d "c/{{package}}" ]; then
        mkdir -p "c/{{package}}/build"
        cd "c/{{package}}/build"
        cmake ..
        make
        ctest
    else
        echo "❌ Package not found: c/{{package}}"
        exit 1
    fi

# Build a C package
build-c package:
    #!/usr/bin/env bash
    if [ -d "c/{{package}}" ]; then
        mkdir -p "c/{{package}}/build"
        cd "c/{{package}}/build"
        cmake ..
        make
    else
        echo "❌ Package not found: c/{{package}}"
        exit 1
    fi

# Clean a C package
clean-c package:
    #!/usr/bin/env bash
    if [ -d "c/{{package}}/build" ]; then
        rm -rf "c/{{package}}/build"
        echo "🧹 Cleaned build artifacts for c/{{package}}"
    else
        echo "⚠️  No build artifacts to clean for c/{{package}}"
    fi

