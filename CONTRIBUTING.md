# Contributing to Data Science Template

Thank you for your interest in contributing to this comprehensive data science template! This guide will help you get started with contributing to the project.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Types of Contributions](#types-of-contributions)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)
- [Community Guidelines](#community-guidelines)

## 🚀 Getting Started

### Prerequisites

- Python 3.11+
- [Git](https://git-scm.com/)
- [Just](https://just.systems/) task runner
- [Copier](https://copier.readthedocs.io/) for template testing

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```shell
   git clone https://github.com/YOUR_USERNAME/abc-project-template.git
   cd abc-project-template
   ```

## 🛠 Development Setup

### Environment Setup

1. **Install dependencies**:
   ```shell
   pip install copier pre-commit pytest
   ```

2. **Install pre-commit hooks**:
   ```shell
   pre-commit install
   ```

### Testing the Template

1. **Generate a test project**:
   ```shell
   copier copy . test-project
   cd test-project
   ```

2. **Test the generated project**:
   ```shell
   just setup
   just --list
   ```

3. **Run template tests**:
   ```shell
   cd ..
   pytest tests/
   ```

## 📝 Contributing Guidelines

### Code Style

- **Python**: Follow PEP 8, enforced by Ruff
- **Shell Scripts**: Follow Google Shell Style Guide
- **Markdown**: Use markdownlint-cli2 rules
- **Commit Messages**: Use conventional commit format

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(notebooks): add enhanced experiment tracking
fix(templates): correct Quarto YAML formatting
docs(readme): update installation instructions
```

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

## 🎯 Types of Contributions

### 1. Template Improvements

#### Adding New Templates
- **Notebook templates**: Add to `template/analysis/notebooks/`
- **Script templates**: Add to `template/analysis/scripts/`
- **Documentation templates**: Add to `template/writeup/`

#### Improving Existing Templates
- Enhance functionality
- Add better examples
- Improve documentation
- Fix bugs

### 2. New Features

#### Infrastructure Components
- **Cloud providers**: AWS, GCP, Azure templates
- **Container orchestration**: Kubernetes manifests
- **CI/CD pipelines**: GitHub Actions, GitLab CI

#### Analysis Tools
- **Data validation**: New validation frameworks
- **Experiment tracking**: Additional platforms
- **Visualization**: New plotting libraries

#### Academic Tools
- **Journal templates**: New publication formats
- **Conference templates**: Presentation formats
- **Grant templates**: Funding agency formats

### 3. Documentation

#### Areas for Improvement
- **User guides**: Step-by-step tutorials
- **Best practices**: Data science workflows
- **Examples**: Real-world use cases
- **API documentation**: Template customization

### 4. Testing

#### Test Categories
- **Template generation**: Copier functionality
- **Generated project**: Project setup and commands
- **Integration**: End-to-end workflows
- **Performance**: Template generation speed

## 🔄 Pull Request Process

### Before Submitting

1. **Test your changes**:
   ```shell
   # Test template generation
   copier copy . test-project-pr
   
   # Test generated project
   cd test-project-pr
   just setup
   just notebooks new-eda "test-eda"
   
   # Run tests
   cd ..
   pytest tests/
   ```

2. **Check code quality**:
   ```shell
   pre-commit run --all-files
   ```

3. **Update documentation** if needed

### Submitting the PR

1. **Create descriptive title**:
   ```
   feat(templates): add MLflow experiment tracking integration
   ```

2. **Write clear description**:
   ```markdown
   ## Changes
   - Added MLflow configuration templates
   - Updated notebook templates with tracking
   - Added documentation for MLflow setup
   
   ## Testing
   - [x] Template generates without errors
   - [x] MLflow integration works
   - [x] Documentation is accurate
   
   ## Breaking Changes
   None
   ```

3. **Link related issues**:
   ```markdown
   Closes #123
   Related to #456
   ```

### Review Process

1. **Automated checks** must pass
2. **Maintainer review** within 1-2 weeks
3. **Community feedback** welcome
4. **Merge** after approval

## 🧪 Testing

### Test Structure

```
tests/
├── test_template_generation.py    # Template generation tests
├── test_generated_project.py      # Generated project tests
├── test_notebooks.py             # Notebook template tests
├── test_writeup.py               # Academic template tests
└── fixtures/                     # Test fixtures
```

### Running Tests

```shell
# All tests
pytest

# Specific test file
pytest tests/test_template_generation.py

# With coverage
pytest --cov=template

# Verbose output
pytest -v
```

### Adding Tests

#### Template Generation Tests
```python
def test_template_generates_with_python():
    """Test template generation with Python configuration."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        copier.run_copy(
            src_path=".",
            dst_path=tmp_dir,
            data={"project_name": "test", "programming_language": "Python"},
            unsafe=True,
        )
        assert (Path(tmp_dir) / "pyproject.toml").exists()
```

#### Generated Project Tests
```python
def test_just_setup_works(generated_project):
    """Test that 'just setup' works in generated project."""
    result = subprocess.run(
        ["just", "setup"],
        cwd=generated_project,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
```

## 📚 Documentation

### Documentation Types

#### User Documentation
- **README files**: Project overview and setup
- **Tutorials**: Step-by-step guides
- **How-to guides**: Specific tasks
- **Reference**: Complete command reference

#### Developer Documentation
- **Contributing guide**: This file
- **Architecture**: Template structure
- **API reference**: Customization options
- **Changelog**: Version history

### Writing Guidelines

- **Clear and concise**: Easy to understand
- **Examples**: Include code examples
- **Updated**: Keep documentation current
- **Accessible**: Consider different skill levels

### Documentation Updates

#### When to Update
- New features added
- Breaking changes made
- Bug fixes that affect usage
- Configuration changes

#### What to Update
- README files
- Command reference
- Examples
- Tutorials

## 🤝 Community Guidelines

### Code of Conduct

We follow the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct. Please be respectful and inclusive in all interactions.

### Getting Help

- **Issues**: Report bugs and request features
- **Discussions**: Ask questions and share ideas
- **Wiki**: Browse detailed documentation
- **Discord/Slack**: Real-time community chat (if available)

### Communication

#### Issue Templates
Use the provided templates for:
- Bug reports
- Feature requests
- Documentation improvements
- Questions

#### Discussions
- **Ideas**: Share new concepts
- **Help**: Ask for assistance
- **Showcase**: Share your projects
- **General**: Open-ended discussions

## 🏆 Recognition

### Contributors

All contributors are recognized in:
- **README.md**: Contributors section
- **CHANGELOG.md**: Release notes
- **GitHub**: Contributor graph

### Types of Recognition

- **Code contributions**: Features, fixes, tests
- **Documentation**: Guides, examples, fixes
- **Community**: Helping others, discussions
- **Ideas**: Feature suggestions, feedback

## 📋 Checklist for Contributors

### Before Contributing
- [ ] Read this contributing guide
- [ ] Check existing issues and PRs
- [ ] Set up development environment
- [ ] Test template generation

### For Each Contribution
- [ ] Create descriptive branch name
- [ ] Write clear commit messages
- [ ] Add/update tests as needed
- [ ] Update documentation
- [ ] Test changes thoroughly
- [ ] Run pre-commit hooks
- [ ] Write descriptive PR description

### After PR Submission
- [ ] Respond to review feedback
- [ ] Update PR as needed
- [ ] Celebrate when merged! 🎉

## 📞 Contact

- **Maintainer**: [@abhi18av](https://github.com/abhi18av)
- **Issues**: [GitHub Issues](https://github.com/abc-cluster/abc-project-template/issues)
- **Discussions**: [GitHub Discussions](https://github.com/abc-cluster/abc-project-template/discussions)

---

Thank you for contributing to making data science more accessible and reproducible! 🙌
