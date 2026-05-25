# Clojure Library Template

This template provides a standardized structure for developing Clojure libraries in academic research contexts.

## Features

- Modern Clojure project structure with deps.edn
- Comprehensive namespace organization
- Clojure.test testing framework
- Academic citation support
- Research-focused protocols and functions
- Data processing and analysis utilities
- Statistical functions and pipelines
- Maven/Clojars distribution ready

## Usage

```bash
just create-clojure-library research-toolkit "Comprehensive research analysis library"
```

## Structure

```
research-toolkit/
├── deps.edn                     # Dependencies and aliases
├── pom.xml                      # Maven configuration
├── build.clj                    # Build script
├── src/research-toolkit/        # Source code
│   └── core.clj                 # Main namespace
├── test/research-toolkit/       # Tests
│   └── core_test.clj           # Test namespace
├── resources/                   # Resources
├── doc/                        # Documentation
├── dev/                        # Development utilities
└── README.md                   # Library documentation
```

## Clojure Components

The template includes:

- **ResearchComponent Protocol**: Standard interface for analysis components
- **ResearchAnalyzer**: Configurable analysis record with fit/transform
- **Data Loading**: CSV/JSON file handling with validation
- **Statistical Functions**: Summary statistics and data quality checks
- **Research Pipeline**: Composable analysis workflows
- **Utility Functions**: Logging, timestamps, and data manipulation

## Distribution

- **Clojars**: Official Clojure package repository
- **Local development**: deps.edn local dependencies
- **Maven Central**: For wider distribution
- **JAR files**: Standalone distribution

## Example Usage

```clojure
(require '[research-toolkit.core :as research])

;; Create and use analysis components
(def analyzer (research/research-analyzer "my-analysis" {:parameter 2.0}))
(def data (research/load-csv "data.csv"))
(def results (research/fit-transform analyzer data))

;; Use research pipeline
(def pipeline-result
  (research/research-pipeline data
                             (research/apply-filter #(> (:value %) 10))
                             (research/apply-transform #(update % :value * 2))
                             (research/apply-analysis count)))

;; Data validation and statistics
(def validation (research/validate-data data))
(def stats (research/summary-stats data))
```

## Research Features

### Protocol-Based Design
- Consistent interface for research components
- Easy extension and customization
- Composable analysis workflows

### Data Processing
- Multiple file format support (CSV, JSON)
- Data validation and quality checks
- Statistical summaries and analysis

### Functional Pipeline
- Composable analysis steps
- Filter, transform, and analysis operations
- Immutable data processing

### Academic Integration
- Citation support built-in
- Reproducible research patterns
- Version tracking and metadata
