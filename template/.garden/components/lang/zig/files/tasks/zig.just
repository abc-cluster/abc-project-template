
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Zig Package Development Automation
# Tools for creating, testing, and building Zig research libraries

# Create a new Zig library package
create-zig-package name description="Research Zig library":
    #!/usr/bin/env bash
    package_dir="zig/{{name}}"
    mkdir -p "${package_dir}/src"
    mkdir -p "${package_dir}/tests"
    
    # Create build.zig for build configuration
    cat > "${package_dir}/build.zig" << 'EOF'
const std = @import("std");

pub fn build(b: *std.Build) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("{{name}}", "src/{{name}}.zig");
    lib.setBuildMode(mode);
    
    const test_step = b.addTest("src/{{name}}.zig");
    test_step.setBuildMode(mode);
    
    const test_cmd = test_step.run();
    test_cmd.step.dependOn(b.getInstallStep());
    
    const test_step_run = b.step("test", "Run library tests");
    test_step_run.dependOn(&test_cmd.step);
}
EOF

    # Create basic Zig source file
    cat > "${package_dir}/src/{{name}}.zig" << 'EOF'
const std = @import("std");

pub fn hello() void {
    std.debug.print("Hello from {{name}}!\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

// Statistical analysis functions for research
pub fn mean(data: []const f64) f64 {
    if (data.len == 0) return 0.0;
    
    var sum: f64 = 0.0;
    for (data) |value| {
        sum += value;
    }
    return sum / @intToFloat(f64, data.len);
}

pub fn variance(data: []const f64) f64 {
    if (data.len == 0) return 0.0;
    
    const m = mean(data);
    var sum_sq_diff: f64 = 0.0;
    
    for (data) |value| {
        const diff = value - m;
        sum_sq_diff += diff * diff;
    }
    
    return sum_sq_diff / @intToFloat(f64, data.len);
}

pub fn stdDev(data: []const f64) f64 {
    return std.math.sqrt(variance(data));
}

test "basic functionality" {
    const testing = std.testing;
    
    // Test add function
    try testing.expect(add(3, 4) == 7);
    
    // Test statistical functions
    const data = [_]f64{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    const m = mean(&data);
    try testing.expect(m == 3.0);
    
    const v = variance(&data);
    try testing.expect(v == 2.0);
}
EOF

    # Create a basic test file
    cat > "${package_dir}/tests/test_{{name}}.zig" << 'EOF'
const std = @import("std");
const testing = std.testing;
const {{name}} = @import("../src/{{name}}.zig");

test "{{name}} hello function" {
    {{name}}.hello();
}

test "{{name}} statistical functions" {
    const data = [_]f64{ 2.0, 4.0, 6.0, 8.0, 10.0 };
    const m = {{name}}.mean(&data);
    try testing.expect(m == 6.0);
    
    const v = {{name}}.variance(&data);
    try testing.expect(v == 8.0);
}
EOF

    echo "📦 Created Zig library: ${package_dir}"
    echo "📝 To build and test:"
    echo "   zig build test"

# Test a Zig package
test-zig package:
    #!/usr/bin/env bash
    if [ -d "zig/{{package}}" ]; then
        cd "zig/{{package}}"
        zig build test
    else
        echo "❌ Package not found: zig/{{package}}"
        exit 1
    fi

# Build a Zig package
build-zig package:
    #!/usr/bin/env bash
    if [ -d "zig/{{package}}" ]; then
        cd "zig/{{package}}"
        zig build
    else
        echo "❌ Package not found: zig/{{package}}"
        exit 1
    fi

# Clean a Zig package
clean-zig package:
    #!/usr/bin/env bash
    if [ -d "zig/{{package}}" ]; then
        rm -rf "zig/{{package}}/.zig-cache"
        echo "🧹 Cleaned build artifacts for zig/{{package}}"
    else
        echo "⚠️  No build artifacts to clean for zig/{{package}}"
    fi

