# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Go Package Development Automation
# Tools for creating, testing, and building Go research libraries

# Create a new Go module package
create-go-package name description="Research Go library":
    #!/usr/bin/env bash
    package_dir="go/{{name}}"
    mkdir -p "${package_dir}"
    cd "${package_dir}"
    
    # Initialize Go module
    go mod init "github.com/{{author_name}}/{{name}}"
    
    # Create basic Go source file
    cat > "{{name}}.go" << 'EOF'
// Package {{name}} provides {{description}}
package {{name}}

import (
    "math"
    "sort"
)

// Stats represents statistical analysis results
type Stats struct {
    Count  int
    Mean   float64
    StdDev float64
    Min    float64
    Max    float64
    Median float64
}

// AnalyzeData computes basic statistics for a slice of float64 values
func AnalyzeData(data []float64) Stats {
    if len(data) == 0 {
        return Stats{}
    }
    
    // Sort data for median calculation
    sorted := make([]float64, len(data))
    copy(sorted, data)
    sort.Float64s(sorted)
    
    // Calculate mean
    sum := 0.0
    for _, v := range data {
        sum += v
    }
    mean := sum / float64(len(data))
    
    // Calculate variance and standard deviation
    variance := 0.0
    for _, v := range data {
        variance += math.Pow(v-mean, 2)
    }
    variance /= float64(len(data))
    stdDev := math.Sqrt(variance)
    
    // Calculate median
    var median float64
    n := len(sorted)
    if n%2 == 0 {
        median = (sorted[n/2-1] + sorted[n/2]) / 2
    } else {
        median = sorted[n/2]
    }
    
    return Stats{
        Count:  len(data),
        Mean:   mean,
        StdDev: stdDev,
        Min:    sorted[0],
        Max:    sorted[n-1],
        Median: median,
    }
}

// Filter filters data based on a predicate function
func Filter(data []float64, predicate func(float64) bool) []float64 {
    var result []float64
    for _, v := range data {
        if predicate(v) {
            result = append(result, v)
        }
    }
    return result
}

// Normalize normalizes data to the range [0, 1]
func Normalize(data []float64) []float64 {
    if len(data) == 0 {
        return data
    }
    
    min, max := data[0], data[0]
    for _, v := range data {
        if v < min {
            min = v
        }
        if v > max {
            max = v
        }
    }
    
    if max == min {
        result := make([]float64, len(data))
        return result // All zeros if all values are the same
    }
    
    result := make([]float64, len(data))
    for i, v := range data {
        result[i] = (v - min) / (max - min)
    }
    return result
}
EOF
    
    # Create test file
    cat > "{{name}}_test.go" << 'EOF'
package {{name}}

import (
    "math"
    "testing"
)

func TestAnalyzeData(t *testing.T) {
    data := []float64{1.0, 2.0, 3.0, 4.0, 5.0}
    stats := AnalyzeData(data)
    
    if stats.Count != 5 {
        t.Errorf("Expected count 5, got %d", stats.Count)
    }
    
    if math.Abs(stats.Mean-3.0) > 1e-9 {
        t.Errorf("Expected mean 3.0, got %f", stats.Mean)
    }
    
    if math.Abs(stats.Min-1.0) > 1e-9 {
        t.Errorf("Expected min 1.0, got %f", stats.Min)
    }
    
    if math.Abs(stats.Max-5.0) > 1e-9 {
        t.Errorf("Expected max 5.0, got %f", stats.Max)
    }
    
    if math.Abs(stats.Median-3.0) > 1e-9 {
        t.Errorf("Expected median 3.0, got %f", stats.Median)
    }
}

func TestAnalyzeDataEmpty(t *testing.T) {
    data := []float64{}
    stats := AnalyzeData(data)
    
    if stats.Count != 0 {
        t.Errorf("Expected count 0 for empty data, got %d", stats.Count)
    }
}

func TestFilter(t *testing.T) {
    data := []float64{1.0, 2.0, 3.0, 4.0, 5.0}
    filtered := Filter(data, func(x float64) bool { return x > 3.0 })
    
    expected := []float64{4.0, 5.0}
    if len(filtered) != len(expected) {
        t.Errorf("Expected length %d, got %d", len(expected), len(filtered))
    }
    
    for i, v := range expected {
        if math.Abs(filtered[i]-v) > 1e-9 {
            t.Errorf("Expected %f at index %d, got %f", v, i, filtered[i])
        }
    }
}

func TestNormalize(t *testing.T) {
    data := []float64{0.0, 5.0, 10.0}
    normalized := Normalize(data)
    
    expected := []float64{0.0, 0.5, 1.0}
    for i, v := range expected {
        if math.Abs(normalized[i]-v) > 1e-9 {
            t.Errorf("Expected %f at index %d, got %f", v, i, normalized[i])
        }
    }
}

func BenchmarkAnalyzeData(b *testing.B) {
    data := make([]float64, 1000)
    for i := range data {
        data[i] = float64(i)
    }
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        AnalyzeData(data)
    }
}
EOF
    
    # Create example main file
    cat > "example/main.go" << 'EOF'
package main

import (
    "fmt"
    "{{name}}"
)

func main() {
    data := []float64{1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0}
    
    fmt.Println("Research Analysis Example")
    fmt.Println("========================")
    
    stats := {{name}}.AnalyzeData(data)
    fmt.Printf("Count: %d\n", stats.Count)
    fmt.Printf("Mean: %.3f\n", stats.Mean)
    fmt.Printf("Std Dev: %.3f\n", stats.StdDev)
    fmt.Printf("Min: %.3f\n", stats.Min)
    fmt.Printf("Max: %.3f\n", stats.Max)
    fmt.Printf("Median: %.3f\n", stats.Median)
    
    // Filter example
    filtered := {{name}}.Filter(data, func(x float64) bool { return x > 5.0 })
    fmt.Printf("\nFiltered (>5): %v\n", filtered)
    
    // Normalization example
    normalized := {{name}}.Normalize(data)
    fmt.Printf("Normalized: %v\n", normalized)
}
EOF
    
    mkdir -p example
    cd example
    go mod init "{{name}}-example"
    go mod edit -replace "{{name}}"=../
    go mod tidy
    cd ..
    
    # Copy template files
    if [ -f "../../templates/go-library/README.md" ]; then
        cp "../../templates/go-library/README.md" README.md
    fi
    
    # Run initial test to ensure everything works
    go test
    
    echo "📦 Created Go package: ${package_dir}"
    echo "📝 To get started:"
    echo "   cd ${package_dir}"
    echo "   go test"
    echo "   go run example/main.go"

# Test a Go package
test-go package:
    #!/usr/bin/env bash
    if [ -d "go/{{package}}" ]; then
        cd "go/{{package}}"
        go test -v
    else
        echo "❌ Package not found: go/{{package}}"
        exit 1
    fi

# Build a Go package
build-go package:
    #!/usr/bin/env bash
    if [ -d "go/{{package}}" ]; then
        cd "go/{{package}}"
        go build
    else
        echo "❌ Package not found: go/{{package}}"
        exit 1
    fi

# Run benchmarks for a Go package
bench-go package:
    #!/usr/bin/env bash
    if [ -d "go/{{package}}" ]; then
        cd "go/{{package}}"
        go test -bench=.
    else
        echo "❌ Package not found: go/{{package}}"
        exit 1
    fi

# Run Go package example
run-go-example package:
    #!/usr/bin/env bash
    if [ -d "go/{{package}}" ]; then
        cd "go/{{package}}/example"
        go run main.go
    else
        echo "❌ Package not found: go/{{package}}"
        exit 1
    fi

# Clean Go package build artifacts
clean-go package:
    #!/usr/bin/env bash
    if [ -d "go/{{package}}" ]; then
        cd "go/{{package}}"
        go clean
        rm -f "{{package}}"
    else
        echo "⚠️  No build artifacts to clean for go/{{package}}"
    fi
