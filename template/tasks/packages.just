# Academic Package Development Automation
# Comprehensive tools for research package lifecycle management

# Set shell for cross-platform compatibility
set shell := ["bash", "-c"]

# Variables
project_name := "{{project_name}}"
author_name := "{{author_name}}"
author_email := "{{author_email}}"
python_version := "{{python_version|default('3.11')}}"

# Default recipe - show available commands
default:
    @echo "📦 Academic Package Development Commands:"
    @just --list

# Import language-specific justfiles
import 'justfiles/python.just'
import 'justfiles/r.just'
import 'justfiles/csharp.just'
import 'justfiles/java.just'
import 'justfiles/fsharp.just'
import 'justfiles/clojure.just'
import 'justfiles/powershell.just'
import 'justfiles/rust.just'
import 'justfiles/c.just'
import 'justfiles/zig.just'
import 'justfiles/groovy.just'
import 'justfiles/go.just'
import 'justfiles/julia.just'
import 'justfiles/ocaml.just'
import 'justfiles/cli.just'
import 'justfiles/distribution.just'
import 'justfiles/validation.just'

# === PACKAGE MANAGEMENT ===

# List all packages across all languages
list-packages:
    @echo "📦 Available Packages:"
    @echo ""
    @echo "Python Packages:"
    @find python -maxdepth 1 -type d ! -name python ! -name __pycache__ ! -name experimental 2>/dev/null | sed 's/python\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "R Packages:"
    @find r -maxdepth 1 -type d ! -name r ! -name experimental 2>/dev/null | sed 's/r\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "C# Packages:"
    @find csharp -maxdepth 1 -type d ! -name csharp ! -name experimental 2>/dev/null | sed 's/csharp\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "Java Packages:"
    @find java -maxdepth 1 -type d ! -name java ! -name experimental 2>/dev/null | sed 's/java\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "F# Packages:"
    @find fsharp -maxdepth 1 -type d ! -name fsharp ! -name experimental 2>/dev/null | sed 's/fsharp\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "Rust Packages:"
    @find rust -maxdepth 1 -type d ! -name rust ! -name experimental 2>/dev/null | sed 's/rust\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "C Libraries:"
    @find c -maxdepth 1 -type d ! -name c ! -name experimental 2>/dev/null | sed 's/c\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "Zig Libraries:"
    @find zig -maxdepth 1 -type d ! -name zig ! -name experimental 2>/dev/null | sed 's/zig\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "CLI Tools:"
    @find tools/cli -maxdepth 1 -type d ! -name cli 2>/dev/null | sed 's/tools\/cli\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "PowerShell Modules:"
    @find powershell -maxdepth 1 -type d ! -name powershell ! -name experimental 2>/dev/null | sed 's/powershell\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "Clojure Libraries:"
    @find clojure -maxdepth 1 -type d ! -name clojure ! -name experimental 2>/dev/null | sed 's/clojure\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "Groovy Libraries:"
    @find groovy -maxdepth 1 -type d ! -name groovy ! -name experimental 2>/dev/null | sed 's/groovy\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "Go Packages:"
    @find go -maxdepth 1 -type d ! -name go ! -name experimental 2>/dev/null | sed 's/go\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "Julia Packages:"
    @find julia -maxdepth 1 -type d ! -name julia ! -name experimental 2>/dev/null | sed 's/julia\///g' | grep -v '^$' | sort || echo "  No packages found"
    @echo ""
    @echo "OCaml Libraries:"
    @find ocaml -maxdepth 1 -type d ! -name ocaml ! -name experimental 2>/dev/null | sed 's/ocaml\///g' | grep -v '^$' | sort || echo "  No packages found"

# Run comprehensive tests for all packages
test-all:
    @echo "🧪 Running tests for all packages..."
    @echo "Testing Python packages..."
    @for pkg in $(find python -maxdepth 1 -type d ! -name python ! -name experimental 2>/dev/null | sed 's/python\///'); do \
        if [ -n "$pkg" ]; then \
            echo "Testing Python package: $pkg"; \
            just test-python "$pkg" || echo "❌ Tests failed for $pkg"; \
        fi \
    done
    @echo "Testing R packages..."
    @for pkg in $(find r -maxdepth 1 -type d ! -name r ! -name experimental 2>/dev/null | sed 's/r\///'); do \
        if [ -n "$pkg" ]; then \
            echo "Testing R package: $pkg"; \
            just test-r "$pkg" || echo "❌ Tests failed for $pkg"; \
        fi \
    done
    @echo "Testing C# packages..."
    @for pkg in $(find csharp -maxdepth 1 -type d ! -name csharp ! -name experimental 2>/dev/null | sed 's/csharp\///'); do \
        if [ -n "$pkg" ]; then \
            echo "Testing C# package: $pkg"; \
            just test-csharp "$pkg" || echo "❌ Tests failed for $pkg"; \
        fi \
    done
    @echo "Testing Java packages..."
    @for pkg in $(find java -maxdepth 1 -type d ! -name java ! -name experimental 2>/dev/null | sed 's/java\///'); do \
        if [ -n "$pkg" ]; then \
            echo "Testing Java package: $pkg"; \
            just test-java "$pkg" || echo "❌ Tests failed for $pkg"; \
        fi \
    done
    @echo "Testing Rust packages..."
    @for pkg in $(find rust -maxdepth 1 -type d ! -name rust ! -name experimental 2>/dev/null | sed 's/rust\///'); do \
        if [ -n "$pkg" ]; then \
            echo "Testing Rust package: $pkg"; \
            just test-rust "$pkg" || echo "❌ Tests failed for $pkg"; \
        fi \
    done

# Clean all build artifacts
clean-all:
    @echo "🧹 Cleaning all build artifacts..."
    @find . -name "target" -type d -exec rm -rf {} + 2>/dev/null || true
    @find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
    @find . -name "build" -type d -exec rm -rf {} + 2>/dev/null || true
    @find . -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true
    @find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    @find . -name "bin" -type d -exec rm -rf {} + 2>/dev/null || true
    @find . -name "obj" -type d -exec rm -rf {} + 2>/dev/null || true
    @echo "✅ Cleanup complete"

# Show package statistics
stats:
    @echo "📊 Package Statistics:"
    @echo ""
    @echo "Python: $(find python -maxdepth 1 -type d ! -name python ! -name experimental 2>/dev/null | wc -l | tr -d ' ') packages"
    @echo "R: $(find r -maxdepth 1 -type d ! -name r ! -name experimental 2>/dev/null | wc -l | tr -d ' ') packages"
    @echo "C#: $(find csharp -maxdepth 1 -type d ! -name csharp ! -name experimental 2>/dev/null | wc -l | tr -d ' ') packages"
    @echo "Java: $(find java -maxdepth 1 -type d ! -name java ! -name experimental 2>/dev/null | wc -l | tr -d ' ') packages"
    @echo "F#: $(find fsharp -maxdepth 1 -type d ! -name fsharp ! -name experimental 2>/dev/null | wc -l | tr -d ' ') packages"
    @echo "Rust: $(find rust -maxdepth 1 -type d ! -name rust ! -name experimental 2>/dev/null | wc -l | tr -d ' ') packages"
    @echo "C: $(find c -maxdepth 1 -type d ! -name c ! -name experimental 2>/dev/null | wc -l | tr -d ' ') libraries"
    @echo "Zig: $(find zig -maxdepth 1 -type d ! -name zig ! -name experimental 2>/dev/null | wc -l | tr -d ' ') libraries"
    @echo "CLI Tools: $(find tools/cli -maxdepth 1 -type d ! -name cli 2>/dev/null | wc -l | tr -d ' ') tools"
    @echo "PowerShell: $(find powershell -maxdepth 1 -type d ! -name powershell ! -name experimental 2>/dev/null | wc -l | tr -d ' ') modules"
    @echo "Clojure: $(find clojure -maxdepth 1 -type d ! -name clojure ! -name experimental 2>/dev/null | wc -l | tr -d ' ') libraries"
    @echo "Groovy: $(find groovy -maxdepth 1 -type d ! -name groovy ! -name experimental 2>/dev/null | wc -l | tr -d ' ') libraries"
    @echo "Go: $(find go -maxdepth 1 -type d ! -name go ! -name experimental 2>/dev/null | wc -l | tr -d ' ') packages"
    @echo "Julia: $(find julia -maxdepth 1 -type d ! -name julia ! -name experimental 2>/dev/null | wc -l | tr -d ' ') packages"
    @echo "OCaml: $(find ocaml -maxdepth 1 -type d ! -name ocaml ! -name experimental 2>/dev/null | wc -l | tr -d ' ') libraries"
