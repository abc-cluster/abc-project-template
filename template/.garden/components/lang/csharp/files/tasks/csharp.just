
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# C# Package Development Automation
# Tools for creating, testing, and building C# research libraries

# Create a new C# library package
create-csharp-package name description="Research C# library":
    #!/usr/bin/env bash
    package_dir="csharp/{{name}}"
    mkdir -p "${package_dir}"
    
    # Create C# project structure
    dotnet new classlib -n "{{name}}" -o "${package_dir}"
    
    # Add test project
    dotnet new xunit -n "{{name}}.Tests" -o "${package_dir}.Tests"
    
    # Create solution and add projects
    dotnet new sln -n "{{name}}" -o "${package_dir}/.."
    dotnet sln "${package_dir}/../{{name}}.sln" add "${package_dir}/{{name}}.csproj"
    dotnet sln "${package_dir}/../{{name}}.sln" add "${package_dir}.Tests/{{name}}.Tests.csproj"
    
    # Add test reference
    dotnet add "${package_dir}.Tests/{{name}}.Tests.csproj" reference "${package_dir}/{{name}}.csproj"
    
    # Copy template files
    if [ -f "templates/csharp-library/README.md" ]; then
        cp "templates/csharp-library/README.md" "${package_dir}/README.md"
    fi
    
    # Create basic research classes
    cat > "${package_dir}/ResearchAnalyzer.cs" << 'EOF'
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace {{name}}
{
    /// <summary>
    /// Main research analysis component for data processing.
    /// </summary>
    public class ResearchAnalyzer
    {
        /// <summary>
        /// Analyzes numerical data and returns statistical results.
        /// </summary>
        /// <param name="data">Array of numerical data to analyze</param>
        /// <returns>Analysis results containing statistical measures</returns>
        public AnalysisResult AnalyzeData(double[] data)
        {
            if (data == null || data.Length == 0)
                throw new ArgumentException("Data cannot be null or empty", nameof(data));

            var mean = data.Average();
            var variance = data.Select(x => Math.Pow(x - mean, 2)).Average();
            var standardDeviation = Math.Sqrt(variance);

            return new AnalysisResult
            {
                Mean = mean,
                StandardDeviation = standardDeviation,
                Variance = variance,
                Count = data.Length,
                Min = data.Min(),
                Max = data.Max()
            };
        }

        /// <summary>
        /// Analyzes numerical data asynchronously.
        /// </summary>
        /// <param name="data">Array of numerical data to analyze</param>
        /// <returns>Task containing analysis results</returns>
        public async Task<AnalysisResult> AnalyzeDataAsync(double[] data)
        {
            return await Task.Run(() => AnalyzeData(data));
        }

        /// <summary>
        /// Analyzes a collection of numerical data.
        /// </summary>
        /// <param name="data">Collection of numerical data to analyze</param>
        /// <returns>Analysis results containing statistical measures</returns>
        public AnalysisResult AnalyzeData(IEnumerable<double> data)
        {
            return AnalyzeData(data.ToArray());
        }
    }
}
EOF
    
    cat > "${package_dir}/AnalysisResult.cs" << 'EOF'
namespace {{name}}
{
    /// <summary>
    /// Container for analysis results with statistical measures.
    /// </summary>
    public class AnalysisResult
    {
        /// <summary>
        /// The arithmetic mean of the analyzed data.
        /// </summary>
        public double Mean { get; set; }

        /// <summary>
        /// The standard deviation of the analyzed data.
        /// </summary>
        public double StandardDeviation { get; set; }

        /// <summary>
        /// The variance of the analyzed data.
        /// </summary>
        public double Variance { get; set; }

        /// <summary>
        /// The number of data points analyzed.
        /// </summary>
        public int Count { get; set; }

        /// <summary>
        /// The minimum value in the analyzed data.
        /// </summary>
        public double Min { get; set; }

        /// <summary>
        /// The maximum value in the analyzed data.
        /// </summary>
        public double Max { get; set; }

        /// <summary>
        /// Returns a string representation of the analysis results.
        /// </summary>
        /// <returns>Formatted string containing all statistical measures</returns>
        public override string ToString()
        {
            return $"Mean: {Mean:F3}, StdDev: {StandardDeviation:F3}, Count: {Count}, Range: [{Min:F3}, {Max:F3}]";
        }
    }
}
EOF
    
    # Create comprehensive test file
    cat > "${package_dir}.Tests/ResearchAnalyzerTests.cs" << 'EOF'
using Xunit;
using System;
using System.Linq;
using {{name}};

namespace {{name}}.Tests
{
    public class ResearchAnalyzerTests
    {
        [Fact]
        public void AnalyzeData_WithValidData_ReturnsCorrectResults()
        {
            // Arrange
            var analyzer = new ResearchAnalyzer();
            var data = new double[] { 1.0, 2.0, 3.0, 4.0, 5.0 };

            // Act
            var result = analyzer.AnalyzeData(data);

            // Assert
            Assert.Equal(3.0, result.Mean, 3);
            Assert.Equal(5, result.Count);
            Assert.Equal(1.0, result.Min);
            Assert.Equal(5.0, result.Max);
            Assert.True(result.StandardDeviation > 0);
        }

        [Fact]
        public void AnalyzeData_WithEmptyArray_ThrowsArgumentException()
        {
            // Arrange
            var analyzer = new ResearchAnalyzer();
            var data = new double[0];

            // Act & Assert
            Assert.Throws<ArgumentException>(() => analyzer.AnalyzeData(data));
        }

        [Fact]
        public void AnalyzeData_WithNullArray_ThrowsArgumentException()
        {
            // Arrange
            var analyzer = new ResearchAnalyzer();

            // Act & Assert
            Assert.Throws<ArgumentException>(() => analyzer.AnalyzeData(null));
        }

        [Fact]
        public void AnalyzeData_WithSingleValue_ReturnsCorrectResults()
        {
            // Arrange
            var analyzer = new ResearchAnalyzer();
            var data = new double[] { 42.0 };

            // Act
            var result = analyzer.AnalyzeData(data);

            // Assert
            Assert.Equal(42.0, result.Mean);
            Assert.Equal(0.0, result.StandardDeviation);
            Assert.Equal(1, result.Count);
            Assert.Equal(42.0, result.Min);
            Assert.Equal(42.0, result.Max);
        }

        [Fact]
        public async void AnalyzeDataAsync_WithValidData_ReturnsCorrectResults()
        {
            // Arrange
            var analyzer = new ResearchAnalyzer();
            var data = new double[] { 2.0, 4.0, 6.0, 8.0, 10.0 };

            // Act
            var result = await analyzer.AnalyzeDataAsync(data);

            // Assert
            Assert.Equal(6.0, result.Mean, 3);
            Assert.Equal(5, result.Count);
        }
    }

    public class AnalysisResultTests
    {
        [Fact]
        public void ToString_ReturnsFormattedString()
        {
            // Arrange
            var result = new AnalysisResult
            {
                Mean = 3.0,
                StandardDeviation = 1.581,
                Count = 5,
                Min = 1.0,
                Max = 5.0
            };

            // Act
            var str = result.ToString();

            // Assert
            Assert.Contains("Mean: 3.000", str);
            Assert.Contains("Count: 5", str);
        }
    }
}
EOF
    
    echo "📦 Created C# package: ${package_dir}"
    echo "📝 To get started:"
    echo "   cd ${package_dir}"
    echo "   dotnet restore"
    echo "   dotnet build"
    echo "   dotnet test ../{{name}}.Tests/"

# Test a C# package
test-csharp package:
    #!/usr/bin/env bash
    if [ -d "csharp/{{package}}" ]; then
        cd "csharp/{{package}}"
        dotnet test
    else
        echo "❌ Package not found: csharp/{{package}}"
        exit 1
    fi

# Build a C# package
build-csharp package:
    #!/usr/bin/env bash
    if [ -d "csharp/{{package}}" ]; then
        cd "csharp/{{package}}"
        dotnet build
    else
        echo "❌ Package not found: csharp/{{package}}"
        exit 1
    fi

# Package a C# library for distribution
pack-csharp package:
    #!/usr/bin/env bash
    if [ -d "csharp/{{package}}" ]; then
        cd "csharp/{{package}}"
        dotnet pack --configuration Release
        echo "📦 NuGet package created in bin/Release/"
    else
        echo "❌ Package not found: csharp/{{package}}"
        exit 1
    fi

# Run C# package in watch mode for development
watch-csharp package:
    #!/usr/bin/env bash
    if [ -d "csharp/{{package}}" ]; then
        cd "csharp/{{package}}"
        dotnet watch test
    else
        echo "❌ Package not found: csharp/{{package}}"
        exit 1
    fi
