# 🚀 Quick Start Guide

## Beginner-Friendly Setup (5 minutes)

### 1. Initialize Your Minimal Project
```bash
# Generate a minimal project from template (accepts all defaults)
copier copy --trust gh:abc-cluster/abc-project-template my-analysis-project
cd my-analysis-project

# Setup development environment
just setup
```

✨ **What you get**: 
- A simple project with notebooks and basic writeup capabilities
- Automatic git repository initialization with first commit
- Ready-to-use development environment
- Perfect for beginners!

### 2. Start Your First Analysis
```bash
# Create your first EDA notebook
just notebooks new-eda "exploratory-analysis"

# Launch Jupyter environment  
just notebooks jupyter
```

### 3. Expand When You're Ready
```bash
# See what you can add to your project
just show-available

# Interactive wizard to add components
just wizard

# Get personalized recommendations
just recommend
```

### 3. Common Workflows

#### **🔬 Exploration Workflow**
1. **Data Acquisition**: `01-data/011_data_extraction/`
2. **Initial EDA**: `02-exploration/021_descriptive_statistics/`
3. **Visualization**: `02-exploration/027_visualization/`

#### **🤖 Modeling Workflow**
1. **Feature Engineering**: `04-feat_eng/041_feature_creation/`
2. **Baseline Models**: `05-models/051_baseline_models/`
3. **Model Evaluation**: `05-models/054_model_evaluation/`

#### **📝 Writing Workflow**
1. **Generate Results**: `analysis/notebooks/07-reports/`
2. **Create Manuscript**: `just writeup manuscript-new "my-paper"`
3. **Submit to Journal**: `writeup/manuscript/submissions/`

### 4. Essential Commands
```bash
# Analysis
just notebooks list                    # Show all notebooks
just analysis pipeline               # Run DVC pipeline
just analysis test-cov              # Run tests with coverage

# Writing
just writeup manuscript-render       # Compile manuscript
just writeup presentation-new       # Create presentation
just writeup export-all            # Export everything to PDF

# Infrastructure
just infrastructure vm-create       # Create analysis VM
just infrastructure docker-build    # Build containers
```

## 📁 Directory Cheat Sheet

| Directory | Purpose | When to Use |
|-----------|---------|-------------|
| `analysis/notebooks/00_scratch/` | Quick experiments | Initial exploration |
| `analysis/notebooks/01-data/` | Data processing | Data pipeline development |
| `analysis/notebooks/02-exploration/` | EDA | Understanding your data |
| `analysis/notebooks/05-models/` | Machine learning | Model development |
| `analysis/scripts/` | Production code | Reusable functions |
| `writeup/manuscript/` | Academic writing | Papers and reports |
| `writeup/grants/` | Funding applications | Grant proposals |

## 🆘 Getting Help

- **Documentation**: See `docs/` directory
- **Templates**: Check `analysis/notebooks/` for examples
- **Commands**: Run `just` to see all available commands
- **Issues**: Common problems in `TROUBLESHOOTING.md`
