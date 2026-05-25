
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Julia Package Development Automation
# Tools for creating, testing, and building Julia research libraries

# Create a new Julia package
create-julia-package name description="Research Julia library":
    #!/usr/bin/env bash
    package_dir="julia/{{name}}"
    mkdir -p "${package_dir}"
    cd "${package_dir}"
    
    # Initialize Julia package using Pkg
    julia -e "using Pkg; Pkg.generate(\"{{name}}\")"
    
    # Move files to correct location
    if [ -d "{{name}}" ]; then
        mv "{{name}}"/* .
        rmdir "{{name}}"
    fi
    
    # Create comprehensive source file
    cat > "src/{{name}}.jl" << 'EOF'
"""
    {{name}}

{{description}}

This Julia package provides research-focused statistical analysis capabilities
with high performance and academic-oriented features.

# Example
```julia
using {{name}}

data = [1.0, 2.0, 3.0, 4.0, 5.0]
result = analyze_data(data)
println("Mean: $(result.mean)")
println("Standard Deviation: $(result.std)")
```
"""
module {{name}}

using Statistics
using StatsBase

export analyze_data, AnalysisResult, filter_data, normalize_data, standardize_data

"""
    AnalysisResult

A structure containing statistical analysis results.

# Fields
- `count::Int`: Number of data points
- `mean::Float64`: Arithmetic mean
- `std::Float64`: Standard deviation
- `var::Float64`: Variance
- `min::Float64`: Minimum value
- `max::Float64`: Maximum value
- `median::Float64`: Median value
- `q1::Float64`: First quartile
- `q3::Float64`: Third quartile
"""
struct AnalysisResult
    count::Int
    mean::Float64
    std::Float64
    var::Float64
    min::Float64
    max::Float64
    median::Float64
    q1::Float64
    q3::Float64
end

"""
    analyze_data(data::AbstractVector{<:Real}) -> AnalysisResult

Perform comprehensive statistical analysis on a vector of numerical data.

# Arguments
- `data`: Vector of numerical values to analyze

# Returns
- `AnalysisResult`: Comprehensive statistical measures

# Example
```julia
data = [1.0, 2.0, 3.0, 4.0, 5.0]
result = analyze_data(data)
println("Mean: $(result.mean), Std: $(result.std)")
```
"""
function analyze_data(data::AbstractVector{<:Real})
    isempty(data) && throw(ArgumentError("Data cannot be empty"))
    
    # Convert to Float64 for consistency
    float_data = Float64.(data)
    
    # Basic statistics
    n = length(float_data)
    mean_val = mean(float_data)
    std_val = std(float_data)
    var_val = var(float_data)
    min_val = minimum(float_data)
    max_val = maximum(float_data)
    median_val = median(float_data)
    
    # Quartiles
    q1_val = quantile(float_data, 0.25)
    q3_val = quantile(float_data, 0.75)
    
    return AnalysisResult(
        n, mean_val, std_val, var_val,
        min_val, max_val, median_val,
        q1_val, q3_val
    )
end

"""
    filter_data(data::AbstractVector{<:Real}, predicate::Function) -> Vector{Float64}

Filter data based on a predicate function.

# Arguments
- `data`: Input data vector
- `predicate`: Function that returns true for elements to keep

# Example
```julia
data = [1.0, 2.0, 3.0, 4.0, 5.0]
filtered = filter_data(data, x -> x > 3.0)  # [4.0, 5.0]
```
"""
function filter_data(data::AbstractVector{<:Real}, predicate::Function)
    return Float64[x for x in data if predicate(x)]
end

"""
    normalize_data(data::AbstractVector{<:Real}) -> Vector{Float64}

Normalize data to the range [0, 1].

# Arguments
- `data`: Input data vector

# Returns
- Normalized data vector

# Example
```julia
data = [0.0, 5.0, 10.0]
normalized = normalize_data(data)  # [0.0, 0.5, 1.0]
```
"""
function normalize_data(data::AbstractVector{<:Real})
    isempty(data) && return Float64[]
    
    float_data = Float64.(data)
    min_val = minimum(float_data)
    max_val = maximum(float_data)
    
    if min_val == max_val
        return zeros(Float64, length(float_data))
    end
    
    return (float_data .- min_val) ./ (max_val - min_val)
end

"""
    standardize_data(data::AbstractVector{<:Real}) -> Vector{Float64}

Standardize data to have mean 0 and standard deviation 1.

# Arguments
- `data`: Input data vector

# Returns
- Standardized data vector (z-scores)

# Example
```julia
data = [1.0, 2.0, 3.0, 4.0, 5.0]
standardized = standardize_data(data)
```
"""
function standardize_data(data::AbstractVector{<:Real})
    isempty(data) && return Float64[]
    
    float_data = Float64.(data)
    mean_val = mean(float_data)
    std_val = std(float_data)
    
    if std_val == 0
        return zeros(Float64, length(float_data))
    end
    
    return (float_data .- mean_val) ./ std_val
end

# Additional convenience functions

"""
    range_data(result::AnalysisResult) -> Float64

Calculate the range (max - min) from analysis results.
"""
range_data(result::AnalysisResult) = result.max - result.min

"""
    iqr_data(result::AnalysisResult) -> Float64

Calculate the interquartile range (Q3 - Q1) from analysis results.
"""
iqr_data(result::AnalysisResult) = result.q3 - result.q1

"""
    coefficient_of_variation(result::AnalysisResult) -> Float64

Calculate the coefficient of variation (std/mean) from analysis results.
"""
function coefficient_of_variation(result::AnalysisResult)
    result.mean == 0 ? NaN : result.std / abs(result.mean)
end

end # module
EOF
    
    # Create comprehensive test file
    cat > "test/runtests.jl" << 'EOF'
using {{name}}
using Test

@testset "{{name}}.jl" begin
    
    @testset "Basic Analysis" begin
        data = [1.0, 2.0, 3.0, 4.0, 5.0]
        result = analyze_data(data)
        
        @test result.count == 5
        @test result.mean ≈ 3.0 atol=1e-10
        @test result.min ≈ 1.0 atol=1e-10
        @test result.max ≈ 5.0 atol=1e-10
        @test result.median ≈ 3.0 atol=1e-10
        @test result.std > 0
    end
    
    @testset "Empty Data" begin
        @test_throws ArgumentError analyze_data(Float64[])
    end
    
    @testset "Single Value" begin
        data = [42.0]
        result = analyze_data(data)
        
        @test result.count == 1
        @test result.mean ≈ 42.0
        @test result.std ≈ 0.0
        @test result.min ≈ 42.0
        @test result.max ≈ 42.0
        @test result.median ≈ 42.0
    end
    
    @testset "Filter Data" begin
        data = [1.0, 2.0, 3.0, 4.0, 5.0]
        filtered = filter_data(data, x -> x > 3.0)
        
        @test filtered == [4.0, 5.0]
    end
    
    @testset "Normalize Data" begin
        data = [0.0, 5.0, 10.0]
        normalized = normalize_data(data)
        
        @test normalized ≈ [0.0, 0.5, 1.0] atol=1e-10
    end
    
    @testset "Standardize Data" begin
        data = [1.0, 2.0, 3.0, 4.0, 5.0]
        standardized = standardize_data(data)
        
        # Mean should be approximately 0
        @test abs(sum(standardized) / length(standardized)) < 1e-10
        
        # Standard deviation should be approximately 1
        @test abs(sqrt(sum((standardized .- mean(standardized)).^2) / length(standardized)) - 1.0) < 1e-10
    end
    
    @testset "Convenience Functions" begin
        data = [1.0, 2.0, 3.0, 4.0, 5.0]
        result = analyze_data(data)
        
        @test range_data(result) ≈ 4.0
        @test iqr_data(result) > 0
        @test !isnan(coefficient_of_variation(result))
    end
    
    @testset "Type Stability" begin
        data_int = [1, 2, 3, 4, 5]
        data_float = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        result_int = analyze_data(data_int)
        result_float = analyze_data(data_float)
        
        @test result_int.mean ≈ result_float.mean
        @test typeof(result_int.mean) == Float64
        @test typeof(result_float.mean) == Float64
    end
end
EOF
    
    # Create example usage file
    cat > "examples/basic_usage.jl" << 'EOF'
using {{name}}

# Basic usage example
println("{{name}} - Basic Usage Example")
println("=" ^ 40)

# Generate some sample data
data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
println("Original data: $data")

# Perform analysis
result = analyze_data(data)
println("\nAnalysis Results:")
println("  Count: $(result.count)")
println("  Mean: $(round(result.mean, digits=3))")
println("  Std Dev: $(round(result.std, digits=3))")
println("  Min: $(result.min)")
println("  Max: $(result.max)")
println("  Median: $(result.median)")
println("  Q1: $(round(result.q1, digits=3))")
println("  Q3: $(round(result.q3, digits=3))")

# Data transformations
println("\nData Transformations:")

# Filter data
filtered = filter_data(data, x -> x > 5.0)
println("  Filtered (>5): $filtered")

# Normalize data
normalized = normalize_data(data)
println("  Normalized: $(round.(normalized, digits=3))")

# Standardize data
standardized = standardize_data(data)
println("  Standardized: $(round.(standardized, digits=3))")

# Additional statistics
println("\nAdditional Statistics:")
println("  Range: $(range_data(result))")
println("  IQR: $(round(iqr_data(result), digits=3))")
println("  CV: $(round(coefficient_of_variation(result), digits=3))")
EOF
    
    mkdir -p examples
    
    # Copy template files
    if [ -f "../../templates/julia-library/README.md" ]; then
        cp "../../templates/julia-library/README.md" README.md
    fi
    
    # Run initial tests
    julia -e "using Pkg; Pkg.activate(\".\"); Pkg.test()"
    
    echo "📦 Created Julia package: ${package_dir}"
    echo "📝 To get started:"
    echo "   cd ${package_dir}"
    echo "   julia -e 'using Pkg; Pkg.activate(\".\"); Pkg.test()'"
    echo "   julia examples/basic_usage.jl"

# Test a Julia package
test-julia package:
    #!/usr/bin/env bash
    if [ -d "julia/{{package}}" ]; then
        cd "julia/{{package}}"
        julia -e "using Pkg; Pkg.activate(\".\"); Pkg.test()"
    else
        echo "❌ Package not found: julia/{{package}}"
        exit 1
    fi

# Build/precompile a Julia package
build-julia package:
    #!/usr/bin/env bash
    if [ -d "julia/{{package}}" ]; then
        cd "julia/{{package}}"
        julia -e "using Pkg; Pkg.activate(\".\"); Pkg.precompile()"
    else
        echo "❌ Package not found: julia/{{package}}"
        exit 1
    fi

# Run Julia package example
run-julia-example package:
    #!/usr/bin/env bash
    if [ -d "julia/{{package}}" ]; then
        cd "julia/{{package}}"
        julia -e "using Pkg; Pkg.activate(\".\")" examples/basic_usage.jl
    else
        echo "❌ Package not found: julia/{{package}}"
        exit 1
    fi

# Start Julia REPL with package loaded
repl-julia package:
    #!/usr/bin/env bash
    if [ -d "julia/{{package}}" ]; then
        cd "julia/{{package}}"
        julia -e "using Pkg; Pkg.activate(\".\"); using {{package}}"
    else
        echo "❌ Package not found: julia/{{package}}"
        exit 1
    fi

# Generate documentation for Julia package
docs-julia package:
    #!/usr/bin/env bash
    if [ -d "julia/{{package}}" ]; then
        cd "julia/{{package}}"
        julia -e "using Pkg; Pkg.activate(\".\"); using Documenter; using {{package}}; makedocs()"
    else
        echo "❌ Package not found: julia/{{package}}"
        exit 1
    fi
