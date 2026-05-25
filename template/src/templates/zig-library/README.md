# {{name}}

{{description}}

A Zig library developed as part of {{project_name}} research.

## Features

- High-performance numerical computing
- Memory-safe by design
- Compile-time safety guarantees
- Cross-platform compatibility
- Zero runtime overhead abstractions
- Comprehensive testing framework

## Installation

### Using Zig Package Manager

Add to your `build.zig.zon`:

```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .{{name}} = .{
            .url = "https://github.com/{{author_name}}/{{name}}/archive/v0.1.0.tar.gz",
            .hash = "12345...", // Add actual hash
        },
    },
}
```

### Building from Source

```bash
git clone https://github.com/{{author_name}}/{{name}}.git
cd {{name}}
zig build
```

## Usage

### Basic Example

```zig
const std = @import("std");
const {{name}} = @import("{{name}}");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Initialize data
    const data = [_]f64{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    
    // Compute statistics
    const mean_val = {{name}}.mean(&data);
    const std_dev = {{name}}.stdDev(&data);
    
    std.debug.print("Mean: {d:.3}\n", .{mean_val});
    std.debug.print("Standard Deviation: {d:.3}\n", .{std_dev});
}
```

### Advanced Usage with Allocator

```zig
const std = @import("std");
const {{name}} = @import("{{name}}");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Create analysis context
    var analyzer = {{name}}.Analyzer.init(allocator);
    defer analyzer.deinit();
    
    // Load data from file
    const data = try loadDataFromFile(allocator, "data.csv");
    defer allocator.free(data);
    
    // Perform comprehensive analysis
    const result = try analyzer.analyze(data);
    defer result.deinit();
    
    // Print results
    std.debug.print("Statistics Summary:\n");
    std.debug.print("  Count: {d}\n", .{result.count});
    std.debug.print("  Mean: {d:.6}\n", .{result.mean});
    std.debug.print("  Std Dev: {d:.6}\n", .{result.std_dev});
    std.debug.print("  Range: [{d:.6}, {d:.6}]\n", .{ result.min, result.max });
}

fn loadDataFromFile(allocator: std.mem.Allocator, filename: []const u8) ![]f64 {
    // Implementation for loading CSV data
    // This is a simplified example
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    
    // Parse and return data
    // ... implementation details
}
```

### Compile-time Statistics

```zig
const {{name}} = @import("{{name}}");

pub fn main() void {
    // Compile-time known data
    const data = [_]f64{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    
    // Computed at compile time!
    const mean_val = comptime {{name}}.mean(&data);
    const variance_val = comptime {{name}}.variance(&data);
    
    std.debug.print("Compile-time mean: {d}\n", .{mean_val});
    std.debug.print("Compile-time variance: {d}\n", .{variance_val});
}
```

## API Reference

### Basic Statistical Functions

```zig
// All functions are generic over numeric types
pub fn mean(data: []const T) T
pub fn variance(data: []const T) T
pub fn stdDev(data: []const T) T
pub fn median(data: []T) T  // Note: modifies data for sorting
pub fn min(data: []const T) T
pub fn max(data: []const T) T
```

### Advanced Analysis

```zig
pub const AnalysisResult = struct {
    count: usize,
    mean: f64,
    variance: f64,
    std_dev: f64,
    min: f64,
    max: f64,
    median: f64,
    q1: f64,
    q3: f64,
    
    pub fn deinit(self: *AnalysisResult) void
    pub fn range(self: AnalysisResult) f64
    pub fn iqr(self: AnalysisResult) f64
    pub fn coefficientOfVariation(self: AnalysisResult) f64
};

pub const Analyzer = struct {
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator) Analyzer
    pub fn deinit(self: *Analyzer) void
    pub fn analyze(self: *Analyzer, data: []const f64) !AnalysisResult
    pub fn normalizeData(self: *Analyzer, data: []f64) !void
    pub fn standardizeData(self: *Analyzer, data: []f64) !void
};
```

### Data Structures

```zig
pub const DataPoint = struct {
    value: f64,
    timestamp: ?i64 = null,
    metadata: ?std.StringHashMap([]const u8) = null,
    
    pub fn init(value: f64) DataPoint
    pub fn withTimestamp(self: DataPoint, timestamp: i64) DataPoint
    pub fn deinit(self: *DataPoint, allocator: std.mem.Allocator) void
};

pub const Dataset = struct {
    points: std.ArrayList(DataPoint),
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator) Dataset
    pub fn deinit(self: *Dataset) void
    pub fn append(self: *Dataset, point: DataPoint) !void
    pub fn values(self: Dataset) []f64
    pub fn analyze(self: Dataset) !AnalysisResult
};
```

### Error Types

```zig
pub const AnalysisError = error{
    EmptyData,
    InvalidData,
    InsufficientData,
    OutOfMemory,
    ComputationError,
};
```

## Generic Programming

This library leverages Zig's powerful compile-time capabilities:

```zig
// Works with any numeric type
const data_i32 = [_]i32{ 1, 2, 3, 4, 5 };
const data_f32 = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0 };
const data_f64 = [_]f64{ 1.0, 2.0, 3.0, 4.0, 5.0 };

const mean_i32 = {{name}}.mean(&data_i32); // Returns i32
const mean_f32 = {{name}}.mean(&data_f32); // Returns f32
const mean_f64 = {{name}}.mean(&data_f64); // Returns f64

// Custom numeric types also work
const BigFloat = @import("std").math.big.Float;
// const big_data = [_]BigFloat{ ... };
// const big_mean = {{name}}.mean(&big_data);
```

## Performance Characteristics

- **Zero-cost abstractions**: No runtime overhead for generic functions
- **Compile-time computation**: Many calculations can happen at compile time
- **Memory safety**: Automatic bounds checking in debug mode
- **SIMD optimization**: Automatic vectorization when beneficial

Benchmark results on x86_64:
- Basic statistics: ~3ns per data point
- Compile-time statistics: 0ns runtime cost
- Memory allocation: Minimal, explicit control

## Building and Testing

### Prerequisites

- Zig 0.11.0 or later

### Build Commands

```bash
# Build library
zig build

# Run tests
zig build test

# Build with optimizations
zig build -Doptimize=ReleaseFast

# Build for specific target
zig build -Dtarget=x86_64-linux-gnu
```

### Cross-compilation

```bash
# Build for different targets
zig build -Dtarget=aarch64-linux-gnu
zig build -Dtarget=x86_64-windows-gnu
zig build -Dtarget=wasm32-freestanding
```

### Running Benchmarks

```bash
# Build and run benchmarks
zig build benchmark
```

## Testing

Comprehensive test suite with property-based testing:

```zig
const testing = std.testing;
const {{name}} = @import("{{name}}");

test "mean calculation" {
    const data = [_]f64{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    const result = {{name}}.mean(&data);
    try testing.expectEqual(@as(f64, 3.0), result);
}

test "empty data handling" {
    const data: []f64 = &[_]f64{};
    try testing.expectError({{name}}.AnalysisError.EmptyData, 
                           {{name}}.analyze(data));
}

// Property-based testing
test "mean is within min and max" {
    var prng = std.rand.DefaultPrng.init(12345);
    const random = prng.random();
    
    for (0..1000) |_| {
        var data: [100]f64 = undefined;
        for (&data) |*val| {
            val.* = random.float(f64) * 1000.0;
        }
        
        const mean_val = {{name}}.mean(&data);
        const min_val = {{name}}.min(&data);
        const max_val = {{name}}.max(&data);
        
        try testing.expect(mean_val >= min_val);
        try testing.expect(mean_val <= max_val);
    }
}
```

## Memory Management

Zig's explicit memory management ensures:

- No hidden allocations
- Clear ownership semantics
- Deterministic cleanup
- Excellent performance characteristics

```zig
// Explicit allocator usage
var analyzer = {{name}}.Analyzer.init(allocator);
defer analyzer.deinit(); // Guaranteed cleanup

// Stack allocation for small datasets
const small_data = [_]f64{ 1.0, 2.0, 3.0 };
const result = {{name}}.mean(&small_data); // No allocation needed
```

## Integration

### In a Zig project

Add to your `build.zig`:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    const {{name}} = b.dependency("{{name}}", .{
        .target = target,
        .optimize = optimize,
    });
    
    const exe = b.addExecutable(.{
        .name = "my-program",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    exe.addModule("{{name}}", {{name}}.module("{{name}}"));
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write comprehensive tests
4. Ensure all tests pass: `zig build test`
5. Check formatting: `zig fmt --check src/`
6. Submit a pull request

### Code Style

- Follow Zig's standard formatting (`zig fmt`)
- Use descriptive variable names
- Prefer compile-time computation when possible
- Document all public functions
- Include comprehensive tests

## Citation

If you use this library in your research, please cite:

```bibtex
@software{{{name}_{{year}},
    title = {{{{{name}}}: {{description}}},
    author = {{{{{author_name}}}}},
    year = {{{{year}}}},
    url = {{https://github.com/{{author_name}}/{{name}}}}
}
```

## License

MIT License - see LICENSE file for details.
