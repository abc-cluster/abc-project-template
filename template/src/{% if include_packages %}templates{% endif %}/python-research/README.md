# Python Research Package Template

This template provides a standardized structure for developing Python packages in academic research contexts.

## Features

- Modern Python packaging with pyproject.toml
- Comprehensive testing with pytest
- Documentation with Sphinx
- Code quality tools (black, isort, flake8)
- Academic citation support
- Research-focused base classes
- Data validation utilities
- Reproducibility features

## Usage

```bash
just create-python-package my_algorithm "Novel machine learning algorithm"
```

## Structure

```
my_algorithm/
├── src/my_algorithm/
│   ├── __init__.py
│   ├── core.py          # Main research components
│   └── utils.py         # Utility functions
├── tests/
│   └── test_core.py     # Comprehensive tests
├── docs/                # Documentation
├── examples/            # Usage examples
├── pyproject.toml       # Modern Python packaging
└── README.md           # Package documentation
```

## Research Components

The template includes:

- `ResearchComponent`: Base class for research algorithms
- Type hints and documentation standards
- Data validation and quality checks
- Metadata and provenance tracking
- Academic citation formatting
