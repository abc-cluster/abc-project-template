
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Rust Package Development Automation
# Tools for creating, testing, and building Rust research libraries

# Create a new Rust library package
create-rust-package name description="Research Rust library":
    #!/usr/bin/env bash
    package_dir="rust/{{name}}"
    mkdir -p "${package_dir}"
    
    # Create Rust library structure
    cd "${package_dir}"
    cargo init --lib --name "{{name}}" .
    
    # Update Cargo.toml with research-focused metadata
    cat > "Cargo.toml" << 'EOF'
[package]
name = "{{name}}"
version = "0.1.0"
edition = "2021"
authors = ["{{author_name}} <{{author_email}}>"]
description = "{{description}}"
license = "MIT"
repository = "https://github.com/{{author_name}}/{{name}}"
documentation = "https://docs.rs/{{name}}"
readme = "README.md"
keywords = ["research", "data-analysis", "statistics", "science"]
categories = ["science", "mathematics"]

[dependencies]
# Core dependencies for research
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
nalgebra = "0.32"
statrs = "0.16"
rayon = "1.7"  # For parallel processing
thiserror = "1.0"
tracing = "0.1"

[dev-dependencies]
# Testing and benchmarking
proptest = "1.2"
criterion = { version = "0.5", features = ["html_reports"] }
approx = "0.5"

[features]
default = []
parallel = ["rayon"]
plotting = []

[[bench]]
name = "analysis_benchmark"
harness = false

[package.metadata.docs.rs]
all-features = true
rustdoc-args = ["--cfg", "docsrs"]
EOF
    
    # Create comprehensive library structure
    cat > "src/lib.rs" << 'EOF'
//! # {{name}}
//! 
//! {{description}}
//! 
//! This library provides research-focused data analysis capabilities with
//! performance optimizations for scientific computing.
//! 
//! ## Features
//! 
//! - Statistical analysis functions
//! - Parallel processing support
//! - Comprehensive error handling
//! - Serializable data structures
//! 
//! ## Example
//! 
//! ```rust
//! use {{name}}::{ResearchAnalyzer, AnalysisResult};
//! 
//! let analyzer = ResearchAnalyzer::new();
//! let data = vec![1.0, 2.0, 3.0, 4.0, 5.0];
//! let result = analyzer.analyze_data(&data)?;
//! 
//! println!("Mean: {:.3}", result.mean());
//! println!("Standard Deviation: {:.3}", result.std_dev());
//! # Ok::<(), Box<dyn std::error::Error>>(())
//! ```

pub mod analyzer;
pub mod error;
pub mod stats;
pub mod types;

pub use analyzer::ResearchAnalyzer;
pub use error::{AnalysisError, Result};
pub use stats::AnalysisResult;
pub use types::DataPoint;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn basic_analysis_test() {
        let analyzer = ResearchAnalyzer::new();
        let data = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        let result = analyzer.analyze_data(&data).unwrap();
        
        assert!((result.mean() - 3.0).abs() < f64::EPSILON);
        assert_eq!(result.count(), 5);
    }
}
EOF
    
    # Create error handling module
    cat > "src/error.rs" << 'EOF'
//! Error types for research analysis operations.

use thiserror::Error;

/// Result type alias for analysis operations.
pub type Result<T> = std::result::Result<T, AnalysisError>;

/// Errors that can occur during data analysis.
#[derive(Error, Debug, Clone, PartialEq)]
pub enum AnalysisError {
    /// Data is empty or contains no valid values.
    #[error("No data provided for analysis")]
    EmptyData,
    
    /// Data contains invalid values (NaN, infinite).
    #[error("Data contains invalid values: {message}")]
    InvalidData { message: String },
    
    /// Insufficient data for the requested analysis.
    #[error("Insufficient data: need at least {required} points, got {actual}")]
    InsufficientData { required: usize, actual: usize },
    
    /// Mathematical operation failed.
    #[error("Mathematical computation failed: {operation}")]
    ComputationError { operation: String },
    
    /// Configuration or parameter error.
    #[error("Configuration error: {details}")]
    ConfigurationError { details: String },
}

impl AnalysisError {
    /// Creates a new invalid data error.
    pub fn invalid_data(message: impl Into<String>) -> Self {
        Self::InvalidData {
            message: message.into(),
        }
    }
    
    /// Creates a new insufficient data error.
    pub fn insufficient_data(required: usize, actual: usize) -> Self {
        Self::InsufficientData { required, actual }
    }
    
    /// Creates a new computation error.
    pub fn computation_error(operation: impl Into<String>) -> Self {
        Self::ComputationError {
            operation: operation.into(),
        }
    }
}
EOF
    
    # Create data types module
    cat > "src/types.rs" << 'EOF'
//! Data types for research analysis.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Represents a single data point with optional metadata.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DataPoint {
    /// The numerical value of the data point.
    pub value: f64,
    /// Optional timestamp for time-series data.
    pub timestamp: Option<chrono::DateTime<chrono::Utc>>,
    /// Additional metadata as key-value pairs.
    pub metadata: HashMap<String, String>,
}

impl DataPoint {
    /// Creates a new data point with just a value.
    pub fn new(value: f64) -> Self {
        Self {
            value,
            timestamp: None,
            metadata: HashMap::new(),
        }
    }
    
    /// Creates a new data point with a value and timestamp.
    pub fn with_timestamp(value: f64, timestamp: chrono::DateTime<chrono::Utc>) -> Self {
        Self {
            value,
            timestamp: Some(timestamp),
            metadata: HashMap::new(),
        }
    }
    
    /// Adds metadata to the data point.
    pub fn with_metadata(mut self, key: String, value: String) -> Self {
        self.metadata.insert(key, value);
        self
    }
    
    /// Returns true if the value is finite (not NaN or infinite).
    pub fn is_valid(&self) -> bool {
        self.value.is_finite()
    }
}

impl From<f64> for DataPoint {
    fn from(value: f64) -> Self {
        Self::new(value)
    }
}

/// Configuration for analysis operations.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnalysisConfig {
    /// Whether to use parallel processing when available.
    pub parallel: bool,
    /// Whether to skip invalid (NaN/infinite) values.
    pub skip_invalid: bool,
    /// Confidence level for statistical computations (0.0 to 1.0).
    pub confidence_level: f64,
}

impl Default for AnalysisConfig {
    fn default() -> Self {
        Self {
            parallel: true,
            skip_invalid: true,
            confidence_level: 0.95,
        }
    }
}
EOF
    
    # Create statistics module
    cat > "src/stats.rs" << 'EOF'
//! Statistical analysis results and computations.

use crate::error::{AnalysisError, Result};
use serde::{Deserialize, Serialize};

/// Container for statistical analysis results.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct AnalysisResult {
    /// Number of data points analyzed.
    count: usize,
    /// Arithmetic mean of the data.
    mean: f64,
    /// Standard deviation of the data.
    std_dev: f64,
    /// Variance of the data.
    variance: f64,
    /// Minimum value in the data.
    min: f64,
    /// Maximum value in the data.
    max: f64,
    /// Median value of the data.
    median: f64,
    /// First quartile (25th percentile).
    q1: f64,
    /// Third quartile (75th percentile).
    q3: f64,
}

impl AnalysisResult {
    /// Creates a new analysis result from raw statistics.
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        count: usize,
        mean: f64,
        std_dev: f64,
        variance: f64,
        min: f64,
        max: f64,
        median: f64,
        q1: f64,
        q3: f64,
    ) -> Self {
        Self {
            count,
            mean,
            std_dev,
            variance,
            min,
            max,
            median,
            q1,
            q3,
        }
    }
    
    /// Computes analysis results from a slice of data.
    pub fn from_data(data: &[f64]) -> Result<Self> {
        if data.is_empty() {
            return Err(AnalysisError::EmptyData);
        }
        
        // Check for invalid values
        let valid_data: Vec<f64> = data.iter()
            .copied()
            .filter(|x| x.is_finite())
            .collect();
            
        if valid_data.is_empty() {
            return Err(AnalysisError::invalid_data("All values are NaN or infinite"));
        }
        
        let count = valid_data.len();
        let mean = valid_data.iter().sum::<f64>() / count as f64;
        
        let variance = valid_data.iter()
            .map(|x| (x - mean).powi(2))
            .sum::<f64>() / count as f64;
            
        let std_dev = variance.sqrt();
        
        let mut sorted_data = valid_data.clone();
        sorted_data.sort_by(|a, b| a.partial_cmp(b).unwrap());
        
        let min = sorted_data[0];
        let max = sorted_data[count - 1];
        
        let median = if count % 2 == 0 {
            (sorted_data[count / 2 - 1] + sorted_data[count / 2]) / 2.0
        } else {
            sorted_data[count / 2]
        };
        
        let q1_idx = count / 4;
        let q3_idx = 3 * count / 4;
        let q1 = sorted_data[q1_idx];
        let q3 = sorted_data[q3_idx.min(count - 1)];
        
        Ok(Self::new(count, mean, std_dev, variance, min, max, median, q1, q3))
    }
    
    // Getters
    pub fn count(&self) -> usize { self.count }
    pub fn mean(&self) -> f64 { self.mean }
    pub fn std_dev(&self) -> f64 { self.std_dev }
    pub fn variance(&self) -> f64 { self.variance }
    pub fn min(&self) -> f64 { self.min }
    pub fn max(&self) -> f64 { self.max }
    pub fn median(&self) -> f64 { self.median }
    pub fn q1(&self) -> f64 { self.q1 }
    pub fn q3(&self) -> f64 { self.q3 }
    
    /// Returns the range (max - min) of the data.
    pub fn range(&self) -> f64 {
        self.max - self.min
    }
    
    /// Returns the interquartile range (Q3 - Q1).
    pub fn iqr(&self) -> f64 {
        self.q3 - self.q1
    }
    
    /// Returns the coefficient of variation (std_dev / mean).
    pub fn coefficient_of_variation(&self) -> f64 {
        if self.mean.abs() < f64::EPSILON {
            f64::NAN
        } else {
            self.std_dev / self.mean.abs()
        }
    }
    
    /// Returns a summary string of the analysis.
    pub fn summary(&self) -> String {
        format!(
            "Analysis Summary: count={}, mean={:.3}, std_dev={:.3}, range=[{:.3}, {:.3}]",
            self.count, self.mean, self.std_dev, self.min, self.max
        )
    }
}

impl std::fmt::Display for AnalysisResult {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.summary())
    }
}
EOF
    
    # Create analyzer module
    cat > "src/analyzer.rs" << 'EOF'
//! Main research analyzer implementation.

use crate::{
    error::{AnalysisError, Result},
    stats::AnalysisResult,
    types::{AnalysisConfig, DataPoint},
};

#[cfg(feature = "parallel")]
use rayon::prelude::*;

/// Main research analysis component for data processing.
#[derive(Debug, Clone)]
pub struct ResearchAnalyzer {
    config: AnalysisConfig,
}

impl Default for ResearchAnalyzer {
    fn default() -> Self {
        Self::new()
    }
}

impl ResearchAnalyzer {
    /// Creates a new research analyzer with default configuration.
    pub fn new() -> Self {
        Self {
            config: AnalysisConfig::default(),
        }
    }
    
    /// Creates a new research analyzer with custom configuration.
    pub fn with_config(config: AnalysisConfig) -> Self {
        Self { config }
    }
    
    /// Analyzes a slice of numerical data.
    pub fn analyze_data(&self, data: &[f64]) -> Result<AnalysisResult> {
        tracing::debug!("Analyzing {} data points", data.len());
        
        if data.is_empty() {
            return Err(AnalysisError::EmptyData);
        }
        
        AnalysisResult::from_data(data)
    }
    
    /// Analyzes a vector of data points, extracting values.
    pub fn analyze_data_points(&self, data: &[DataPoint]) -> Result<AnalysisResult> {
        if data.is_empty() {
            return Err(AnalysisError::EmptyData);
        }
        
        let values: Vec<f64> = if self.config.skip_invalid {
            data.iter()
                .filter(|dp| dp.is_valid())
                .map(|dp| dp.value)
                .collect()
        } else {
            data.iter().map(|dp| dp.value).collect()
        };
        
        self.analyze_data(&values)
    }
    
    /// Analyzes data with parallel processing (if enabled and available).
    #[cfg(feature = "parallel")]
    pub fn analyze_data_parallel(&self, data: &[f64]) -> Result<AnalysisResult> {
        if !self.config.parallel || data.len() < 1000 {
            return self.analyze_data(data);
        }
        
        tracing::debug!("Using parallel analysis for {} data points", data.len());
        
        // Parallel computation of basic statistics
        let count = data.len();
        let sum = data.par_iter().sum::<f64>();
        let mean = sum / count as f64;
        
        let variance = data.par_iter()
            .map(|x| (x - mean).powi(2))
            .sum::<f64>() / count as f64;
            
        let std_dev = variance.sqrt();
        
        // Sequential operations for order-dependent computations
        let mut sorted_data = data.to_vec();
        sorted_data.sort_by(|a, b| a.partial_cmp(b).unwrap());
        
        let min = sorted_data[0];
        let max = sorted_data[count - 1];
        
        let median = if count % 2 == 0 {
            (sorted_data[count / 2 - 1] + sorted_data[count / 2]) / 2.0
        } else {
            sorted_data[count / 2]
        };
        
        let q1_idx = count / 4;
        let q3_idx = 3 * count / 4;
        let q1 = sorted_data[q1_idx];
        let q3 = sorted_data[q3_idx.min(count - 1)];
        
        Ok(AnalysisResult::new(count, mean, std_dev, variance, min, max, median, q1, q3))
    }
    
    #[cfg(not(feature = "parallel"))]
    pub fn analyze_data_parallel(&self, data: &[f64]) -> Result<AnalysisResult> {
        self.analyze_data(data)
    }
    
    /// Filters data based on a predicate function.
    pub fn filter_data(&self, data: &[f64], predicate: impl Fn(f64) -> bool) -> Vec<f64> {
        data.iter().copied().filter(|&x| predicate(x)).collect()
    }
    
    /// Normalizes data to the range [0, 1].
    pub fn normalize_data(&self, data: &[f64]) -> Result<Vec<f64>> {
        if data.is_empty() {
            return Err(AnalysisError::EmptyData);
        }
        
        let min = data.iter().fold(f64::INFINITY, |a, &b| a.min(b));
        let max = data.iter().fold(f64::NEG_INFINITY, |a, &b| a.max(b));
        
        if (max - min).abs() < f64::EPSILON {
            return Ok(vec![0.0; data.len()]);
        }
        
        Ok(data.iter()
            .map(|&x| (x - min) / (max - min))
            .collect())
    }
    
    /// Standardizes data to have mean 0 and standard deviation 1.
    pub fn standardize_data(&self, data: &[f64]) -> Result<Vec<f64>> {
        let result = self.analyze_data(data)?;
        let mean = result.mean();
        let std_dev = result.std_dev();
        
        if std_dev.abs() < f64::EPSILON {
            return Ok(vec![0.0; data.len()]);
        }
        
        Ok(data.iter()
            .map(|&x| (x - mean) / std_dev)
            .collect())
    }
    
    /// Returns the current configuration.
    pub fn config(&self) -> &AnalysisConfig {
        &self.config
    }
    
    /// Updates the analyzer configuration.
    pub fn set_config(&mut self, config: AnalysisConfig) {
        self.config = config;
    }
}
EOF
    
    # Create basic tests
    cat > "src/tests.rs" << 'EOF'
#[cfg(test)]
mod tests {
    use super::*;
    use approx::assert_relative_eq;

    #[test]
    fn test_basic_analysis() {
        let analyzer = ResearchAnalyzer::new();
        let data = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        let result = analyzer.analyze_data(&data).unwrap();
        
        assert_relative_eq!(result.mean(), 3.0, epsilon = 1e-10);
        assert_eq!(result.count(), 5);
        assert_relative_eq!(result.min(), 1.0, epsilon = 1e-10);
        assert_relative_eq!(result.max(), 5.0, epsilon = 1e-10);
    }

    #[test]
    fn test_empty_data() {
        let analyzer = ResearchAnalyzer::new();
        let data: Vec<f64> = vec![];
        let result = analyzer.analyze_data(&data);
        
        assert!(matches!(result, Err(AnalysisError::EmptyData)));
    }

    #[test]
    fn test_normalization() {
        let analyzer = ResearchAnalyzer::new();
        let data = vec![0.0, 5.0, 10.0];
        let normalized = analyzer.normalize_data(&data).unwrap();
        
        assert_relative_eq!(normalized[0], 0.0, epsilon = 1e-10);
        assert_relative_eq!(normalized[1], 0.5, epsilon = 1e-10);
        assert_relative_eq!(normalized[2], 1.0, epsilon = 1e-10);
    }

    #[test]
    fn test_standardization() {
        let analyzer = ResearchAnalyzer::new();
        let data = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        let standardized = analyzer.standardize_data(&data).unwrap();
        
        // Mean should be approximately 0
        let std_mean = standardized.iter().sum::<f64>() / standardized.len() as f64;
        assert_relative_eq!(std_mean, 0.0, epsilon = 1e-10);
    }

    #[test]
    fn test_data_points() {
        let analyzer = ResearchAnalyzer::new();
        let data_points = vec![
            DataPoint::new(1.0),
            DataPoint::new(2.0),
            DataPoint::new(3.0),
        ];
        
        let result = analyzer.analyze_data_points(&data_points).unwrap();
        assert_relative_eq!(result.mean(), 2.0, epsilon = 1e-10);
    }
}
EOF
    
    # Copy template README if available
    if [ -f "../../templates/rust-library/README.md" ]; then
        cp "../../templates/rust-library/README.md" "README.md"
    else
        cat > "README.md" << 'EOF'
# {{name}}

{{description}}

A Rust library developed as part of {{project_name}} research.

## Features

- High-performance statistical analysis
- Memory-safe data processing
- Parallel computation support
- Comprehensive error handling
- Serializable data structures

## Installation

Add this to your `Cargo.toml`:

```toml
[dependencies]
{{name}} = "0.1.0"
```

## Usage

```rust
use {{name}}::{ResearchAnalyzer, AnalysisResult};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let analyzer = ResearchAnalyzer::new();
    let data = vec![1.0, 2.0, 3.0, 4.0, 5.0];
    let result = analyzer.analyze_data(&data)?;
    
    println!("Mean: {:.3}", result.mean());
    println!("Standard Deviation: {:.3}", result.std_dev());
    println!("Range: [{:.3}, {:.3}]", result.min(), result.max());
    
    Ok(())
}
```

## License

MIT License - see LICENSE file for details.
EOF
    fi
    
    echo "🦀 Created Rust package: ${package_dir}"
    echo "📝 To get started:"
    echo "   cd ${package_dir}"
    echo "   cargo build"
    echo "   cargo test"
    echo "   cargo doc --open"

# Test a Rust package
test-rust package:
    #!/usr/bin/env bash
    if [ -d "rust/{{package}}" ]; then
        cd "rust/{{package}}"
        cargo test
    else
        echo "❌ Package not found: rust/{{package}}"
        exit 1
    fi

# Build a Rust package
build-rust package:
    #!/usr/bin/env bash
    if [ -d "rust/{{package}}" ]; then
        cd "rust/{{package}}"
        cargo build
    else
        echo "❌ Package not found: rust/{{package}}"
        exit 1
    fi

# Build a Rust package in release mode
build-rust-release package:
    #!/usr/bin/env bash
    if [ -d "rust/{{package}}" ]; then
        cd "rust/{{package}}"
        cargo build --release
    else
        echo "❌ Package not found: rust/{{package}}"
        exit 1
    fi

# Run benchmarks for a Rust package
bench-rust package:
    #!/usr/bin/env bash
    if [ -d "rust/{{package}}" ]; then
        cd "rust/{{package}}"
        cargo bench
    else
        echo "❌ Package not found: rust/{{package}}"
        exit 1
    fi

# Check Rust package for errors and warnings
check-rust package:
    #!/usr/bin/env bash
    if [ -d "rust/{{package}}" ]; then
        cd "rust/{{package}}"
        cargo check
        cargo clippy -- -D warnings
        cargo fmt -- --check
    else
        echo "❌ Package not found: rust/{{package}}"
        exit 1
    fi

# Generate documentation for a Rust package
docs-rust package:
    #!/usr/bin/env bash
    if [ -d "rust/{{package}}" ]; then
        cd "rust/{{package}}"
        cargo doc --open
    else
        echo "❌ Package not found: rust/{{package}}"
        exit 1
    fi

# Run a Rust package in watch mode for development
watch-rust package:
    #!/usr/bin/env bash
    if [ -d "rust/{{package}}" ]; then
        cd "rust/{{package}}"
        cargo watch -x test
    else
        echo "❌ Package not found: rust/{{package}}"
        exit 1
    fi
