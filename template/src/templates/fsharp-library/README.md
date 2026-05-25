# {{name}}

{{description}}

An F# library developed as part of {{project_name}} research.

## Features

- Functional programming paradigms for research
- Type-safe data processing
- Immutable data structures
- Comprehensive unit testing with xUnit
- NuGet package support
- Cross-platform compatibility (.NET 6+)
- Academic citation support

## Installation

### NuGet Package (when published)
```bash
dotnet add package {{name}}
```

### Paket (when published)
```
nuget {{name}}
```

### Local Development
```bash
git clone https://github.com/{{author_name}}/{{name}}.git
cd {{name}}
dotnet restore
dotnet build
```

## Usage

```fsharp
open {{name}}

// Example usage
let data = [1.0; 2.0; 3.0; 4.0; 5.0]
let results = ResearchAnalyzer.analyzeData data

printfn "Mean: %f" results.Mean
printfn "Standard Deviation: %f" results.StandardDeviation
```

### Pipeline-style Usage
```fsharp
open {{name}}

// Functional pipeline approach
let processData data =
    data
    |> List.filter (fun x -> x > 0.0)
    |> ResearchAnalyzer.analyzeData
    |> fun result -> 
        { result with 
            Metadata = Map.add "ProcessingDate" (System.DateTime.Now.ToString()) result.Metadata }

let results = [1.0; -1.0; 2.0; 3.0; 4.0; 5.0] |> processData
```

## API Reference

### Core Types

#### `AnalysisResult`
Immutable record containing analysis results.

```fsharp
type AnalysisResult = {
    Mean: float
    StandardDeviation: float
    Variance: float
    Count: int
    Min: float
    Max: float
    Metadata: Map<string, string>
}
```

#### `DataPoint`
Represents a single data observation.

```fsharp
type DataPoint = {
    Value: float
    Timestamp: System.DateTime option
    Labels: Map<string, string>
}
```

### Core Modules

#### `ResearchAnalyzer`
Main module for data analysis functions.

```fsharp
module ResearchAnalyzer =
    val analyzeData : float list -> AnalysisResult
    val analyzeDataPoints : DataPoint list -> AnalysisResult
    val analyzeDataAsync : float list -> Async<AnalysisResult>
    val summarizeData : float list -> string
```

#### `DataProcessing`
Utilities for data transformation and filtering.

```fsharp
module DataProcessing =
    val normalize : float list -> float list
    val standardize : float list -> float list
    val removeOutliers : float -> float list -> float list
    val interpolate : float list -> float list
```

## Development

### Building
```bash
dotnet build
```

### Testing
```bash
dotnet test
```

### Interactive Development
```bash
# Start F# Interactive
dotnet fsi

# Load the library
#load "src/{{name}}/Library.fs"
open {{name}}
```

### Packaging
```bash
dotnet pack
```

### Code Quality
```bash
# Format code
dotnet fantomas --recurse src/

# Check formatting
dotnet fantomas --check --recurse src/
```

## Project Structure

```
src/
├── {{name}}/
│   ├── Library.fs              # Main library code
│   ├── ResearchAnalyzer.fs     # Core analysis functions
│   ├── DataProcessing.fs       # Data transformation utilities
│   ├── Types.fs                # Type definitions
│   └── {{name}}.fsproj         # Project file
tests/
├── {{name}}.Tests/
│   ├── AnalyzerTests.fs        # Unit tests for analyzer
│   ├── DataProcessingTests.fs  # Unit tests for data processing
│   └── {{name}}.Tests.fsproj   # Test project file
examples/
└── BasicUsage.fs               # Usage examples
```

## Dependencies

### Core Dependencies
- .NET 6+ (required)
- FSharp.Core
- System.Numerics

### Development Dependencies
- xUnit (testing framework)
- FsUnit (F#-friendly test assertions)
- Fantomas (code formatter)

## Functional Programming Features

### Immutability
All data structures are immutable by default, ensuring thread safety and predictable behavior.

### Pattern Matching
```fsharp
let processResult result =
    match result.Count with
    | 0 -> "No data"
    | 1 -> sprintf "Single value: %f" result.Mean
    | n when n < 10 -> sprintf "Small dataset (%d values)" n
    | _ -> sprintf "Large dataset: %f ± %f" result.Mean result.StandardDeviation
```

### Computation Expressions
```fsharp
// Async computation
let analyzeDatasets datasets = async {
    let! results = 
        datasets 
        |> List.map ResearchAnalyzer.analyzeDataAsync
        |> Async.Parallel
    
    return results |> Array.toList
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following F# conventions
4. Add tests for new functionality
5. Ensure all tests pass: `dotnet test`
6. Format code: `dotnet fantomas --recurse src/`
7. Submit a pull request

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
