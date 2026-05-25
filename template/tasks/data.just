#!/usr/bin/env just --justfile
# Data Management Automation System
# Enhanced data pipeline with validation, quality checks, and academic research features

# Default recipes
default:
    @echo "🔬 Data Management Automation System"
    @echo ""
    @echo "📥 Data Ingestion & Registration:"
    @echo "  just data::download-external <url> <name>     - Download and catalog external datasets"
    @echo "  just data::register-internal <path> <name> <description> - Register internal datasets"
    @echo "  just data::generate-synthetic <name> <type> <size> - Generate synthetic datasets"
    @echo ""
    @echo "✅ Data Validation & Quality:"
    @echo "  just data::validate-dataset <path>            - Comprehensive data validation"
    @echo "  just data::profile-dataset <path>             - Statistical profiling"
    @echo "  just data::quality-report <path>              - Detailed quality assessment"
    @echo ""
    @echo "🔄 Data Processing:"
    @echo "  just data::clean-dataset <source> <target>    - Automated data cleaning"
    @echo "  just data::split-dataset <source> <target>    - Train/validation/test splits"
    @echo ""
    @echo "📊 Registry Management:"
    @echo "  just data::register-dataset <name> <path> <type> - Central dataset registry"
    @echo "  just data::list-datasets                      - Browse registered datasets"
    @echo ""
    @echo "💾 Backup & Versioning:"
    @echo "  just data::backup-dataset <path> <name>       - Create versioned backups"
    @echo "  just data::restore-dataset <backup_name>      - Restore from backup"
    @echo ""
    @echo "🎓 Academic Workflows:"
    @echo "  just data::prepare-publication <dataset> <paper_name> - Prepare for publication"
    @echo "  just data::add-benchmark <n> <path>        - Add benchmark dataset"
    @echo "  just data::setup-collaboration <project_name> - Setup collaboration structure"
    @echo ""
    @echo "🧬 Nextflow Pipeline Management:"
    @echo "  just data::nextflow-set-pipeline <name>              - Set current pipeline"
    @echo "  just data::nextflow-get-pipeline                     - Show current pipeline"
    @echo "  just data::nextflow-run-experiment <analysis> <dataset> - Run current pipeline"
    @echo "  just data::nextflow-run-with-pipeline <pipeline> <analysis> <dataset> - Run specific pipeline"
    @echo "  just data::nextflow-list-analyses                    - List all analyses"
    @echo "  just data::nextflow-analysis-results <analysis>      - View analysis results"
    @echo "  just data::nextflow-publish-analysis <analysis> <run_id> <dest> - Publish results"
    @echo "  just data::nextflow-clean-work <analysis> [days=7]   - Clean work directories"
    @echo "  just data::nextflow-create-pipeline <name>           - Create new pipeline"

# Variables
TIMESTAMP := `date +%Y%m%d_%H%M%S`
DATE := `date +%Y%m%d`
DATA_REGISTRY := "data_registry.yaml"

# Data Ingestion & Registration
download-external url name:
    #!/usr/bin/env python3
    python3 .justscripts/download-external.py

    url = "{{url}}"
    name = "{{name}}"
    timestamp = "{{DATE}}"

    # Create target directory
    target_dir = Path("01_raw/011_external")
    target_dir.mkdir(parents=True, exist_ok=True)

    # Download file
    filename = f"{name}_{timestamp}.csv"
    filepath = target_dir / filename

    print(f"📥 Downloading {url} to {filepath}")
    urllib.request.urlretrieve(url, filepath)

    # Calculate checksum
    with open(filepath, 'rb') as f:
        checksum = hashlib.sha256(f.read()).hexdigest()

    # Create metadata
    metadata = {
        'name': name,
        'source_url': url,
        'downloaded_at': datetime.now().isoformat(),
        'filepath': str(filepath),
        'checksum': checksum,
        'size_bytes': filepath.stat().st_size
    }

    # Save metadata
    metadata_file = target_dir / f"{filename}.metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(metadata, f, default_flow_style=False)

    print(f"✅ Downloaded and cataloged: {filepath}")
    print(f"📄 Metadata saved: {metadata_file}")

register-internal path name description:
    #!/usr/bin/env python3
    import os
    import hashlib
    import yaml
    from datetime import datetime
    from pathlib import Path

    source_path = Path("{{path}}")
    name = "{{name}}"
    description = "{{description}}"
    timestamp = "{{DATE}}"

    if not source_path.exists():
        print(f"❌ Source file not found: {source_path}")
        exit(1)

    # Create target directory
    target_dir = Path("01_raw/012_internal")
    target_dir.mkdir(parents=True, exist_ok=True)

    # Copy to internal directory
    filename = f"{name}_{timestamp}{source_path.suffix}"
    target_path = target_dir / filename

    import shutil
    shutil.copy2(source_path, target_path)

    # Calculate checksum
    with open(target_path, 'rb') as f:
        checksum = hashlib.sha256(f.read()).hexdigest()

    # Create metadata
    metadata = {
        'name': name,
        'description': description,
        'source_path': str(source_path),
        'registered_at': datetime.now().isoformat(),
        'filepath': str(target_path),
        'checksum': checksum,
        'size_bytes': target_path.stat().st_size
    }

    # Save metadata
    metadata_file = target_dir / f"{filename}.metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(metadata, f, default_flow_style=False)

    print(f"✅ Registered internal dataset: {target_path}")
    print(f"📄 Metadata saved: {metadata_file}")

generate-synthetic name type size:
    #!/usr/bin/env python3
    python3 .justscripts/generate-synthetic.py

    name = "{{name}}"
    data_type = "{{type}}"
    size = int("{{size}}")
    timestamp = "{{DATE}}"

    # Create target directory
    target_dir = Path("01_raw/013_synthetic")
    target_dir.mkdir(parents=True, exist_ok=True)

    # Generate synthetic data based on type
    if data_type == "tabular":
        df = pd.DataFrame({
            'id': range(1, size + 1),
            'feature_1': np.random.normal(0, 1, size),
            'feature_2': np.random.normal(5, 2, size),
            'feature_3': np.random.choice(['A', 'B', 'C'], size),
            'target': np.random.choice([0, 1], size)
        })
    elif data_type == "timeseries":
        dates = pd.date_range('2023-01-01', periods=size, freq='D')
        df = pd.DataFrame({
            'date': dates,
            'value': np.random.normal(100, 15, size) + np.sin(np.arange(size) * 2 * np.pi / 365) * 10
        })
    else:
        print(f"❌ Unsupported data type: {data_type}")
        exit(1)

    # Save dataset
    filename = f"{name}_{data_type}_{timestamp}.csv"
    filepath = target_dir / filename
    df.to_csv(filepath, index=False)

    # Create metadata
    metadata = {
        'name': name,
        'type': data_type,
        'size': size,
        'generated_at': datetime.now().isoformat(),
        'filepath': str(filepath),
        'columns': list(df.columns),
        'shape': list(df.shape)
    }

    # Save metadata
    metadata_file = target_dir / f"{filename}.metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(metadata, f, default_flow_style=False)

    print(f"✅ Generated synthetic {data_type} dataset: {filepath}")
    print(f"📊 Shape: {df.shape}")
    print(f"📄 Metadata saved: {metadata_file}")

# Data Validation & Quality Assessment
validate-dataset path:
    #!/usr/bin/env python3
    import pandas as pd
    import numpy as np
    import yaml
    from pathlib import Path
    from datetime import datetime

    filepath = Path("{{path}}")

    if not filepath.exists():
        print(f"❌ File not found: {filepath}")
        exit(1)

    print(f"🔍 Validating dataset: {filepath}")

    # Load data
    try:
        if filepath.suffix.lower() == '.csv':
            df = pd.read_csv(filepath)
        elif filepath.suffix.lower() in ['.xlsx', '.xls']:
            df = pd.read_excel(filepath)
        else:
            print(f"❌ Unsupported file format: {filepath.suffix}")
            exit(1)
    except Exception as e:
        print(f"❌ Error loading file: {e}")
        exit(1)

    # Validation checks
    validation_results = {
        'filepath': str(filepath),
        'validated_at': datetime.now().isoformat(),
        'basic_info': {
            'shape': list(df.shape),
            'columns': list(df.columns),
            'dtypes': {col: str(dtype) for col, dtype in df.dtypes.items()}
        },
        'quality_metrics': {},
        'issues': []
    }

    # Completeness score
    total_cells = df.shape[0] * df.shape[1]
    missing_cells = df.isnull().sum().sum()
    completeness = ((total_cells - missing_cells) / total_cells) * 100 if total_cells > 0 else 0
    validation_results['quality_metrics']['completeness'] = round(completeness, 2)

    # Uniqueness score (for rows)
    duplicate_rows = df.duplicated().sum()
    uniqueness = ((df.shape[0] - duplicate_rows) / df.shape[0]) * 100 if df.shape[0] > 0 else 0
    validation_results['quality_metrics']['uniqueness'] = round(uniqueness, 2)

    # Data type consistency
    consistency_issues = 0
    for col in df.columns:
        if df[col].dtype == 'object':
            # Check for mixed types in object columns
            non_null_values = df[col].dropna()
            if len(non_null_values) > 0:
                first_type = type(non_null_values.iloc[0])
                mixed_types = any(type(val) != first_type for val in non_null_values)
                if mixed_types:
                    consistency_issues += 1
                    validation_results['issues'].append(f"Mixed data types in column '{col}'")

    consistency = ((len(df.columns) - consistency_issues) / len(df.columns)) * 100 if len(df.columns) > 0 else 0
    validation_results['quality_metrics']['consistency'] = round(consistency, 2)

    # Overall quality score
    overall_score = (completeness + uniqueness + consistency) / 3
    validation_results['quality_metrics']['overall_score'] = round(overall_score, 2)

    # Check for common issues
    if missing_cells > 0:
        validation_results['issues'].append(f"Missing values: {missing_cells} cells ({missing_cells/total_cells*100:.1f}%)")

    if duplicate_rows > 0:
        validation_results['issues'].append(f"Duplicate rows: {duplicate_rows}")

    # Check for outliers in numeric columns
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    for col in numeric_cols:
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1
        outliers = df[(df[col] < Q1 - 1.5 * IQR) | (df[col] > Q3 + 1.5 * IQR)][col].count()
        if outliers > 0:
            validation_results['issues'].append(f"Outliers in '{col}': {outliers} values")

    # Save validation report
    report_dir = Path("02_intermediate/021_validated")
    report_dir.mkdir(parents=True, exist_ok=True)
    report_file = report_dir / f"{filepath.stem}_validation_report.yaml"

    with open(report_file, 'w') as f:
        yaml.dump(validation_results, f, default_flow_style=False)

    # Print summary
    print(f"\n📊 Validation Results:")
    print(f"   Shape: {df.shape}")
    print(f"   Completeness: {validation_results['quality_metrics']['completeness']:.1f}%")
    print(f"   Uniqueness: {validation_results['quality_metrics']['uniqueness']:.1f}%")
    print(f"   Consistency: {validation_results['quality_metrics']['consistency']:.1f}%")
    print(f"   Overall Score: {validation_results['quality_metrics']['overall_score']:.1f}/100")

    if validation_results['issues']:
        print(f"\n⚠️  Issues Found:")
        for issue in validation_results['issues']:
            print(f"   - {issue}")
    else:
        print(f"\n✅ No issues found!")

    print(f"\n📄 Report saved: {report_file}")

profile-dataset path:
    #!/usr/bin/env python3
    python3 .justscripts/profile-dataset.py

    filepath = Path("{{path}}")

    if not filepath.exists():
        print(f"❌ File not found: {filepath}")
        exit(1)

    print(f"📈 Profiling dataset: {filepath}")

    # Load data
    try:
        if filepath.suffix.lower() == '.csv':
            df = pd.read_csv(filepath)
        elif filepath.suffix.lower() in ['.xlsx', '.xls']:
            df = pd.read_excel(filepath)
        else:
            print(f"❌ Unsupported file format: {filepath.suffix}")
            exit(1)
    except Exception as e:
        print(f"❌ Error loading file: {e}")
        exit(1)

    # Generate profile
    profile = {
        'filepath': str(filepath),
        'profiled_at': datetime.now().isoformat(),
        'dataset_info': {
            'shape': list(df.shape),
            'memory_usage_mb': round(df.memory_usage(deep=True).sum() / 1024 / 1024, 2),
            'columns': list(df.columns)
        },
        'column_profiles': {}
    }

    # Profile each column
    for col in df.columns:
        col_profile = {
            'dtype': str(df[col].dtype),
            'null_count': int(df[col].isnull().sum()),
            'null_percentage': round(df[col].isnull().sum() / len(df) * 100, 2),
            'unique_count': int(df[col].nunique()),
            'unique_percentage': round(df[col].nunique() / len(df) * 100, 2)
        }

        if df[col].dtype in ['int64', 'float64', 'int32', 'float32']:
            # Numeric column statistics
            col_profile.update({
                'min': float(df[col].min()) if pd.notna(df[col].min()) else None,
                'max': float(df[col].max()) if pd.notna(df[col].max()) else None,
                'mean': float(df[col].mean()) if pd.notna(df[col].mean()) else None,
                'median': float(df[col].median()) if pd.notna(df[col].median()) else None,
                'std': float(df[col].std()) if pd.notna(df[col].std()) else None,
                'quantiles': {
                    'q25': float(df[col].quantile(0.25)) if pd.notna(df[col].quantile(0.25)) else None,
                    'q75': float(df[col].quantile(0.75)) if pd.notna(df[col].quantile(0.75)) else None
                }
            })
        elif df[col].dtype == 'object':
            # Text/categorical column statistics
            value_counts = df[col].value_counts().head(10)
            col_profile.update({
                'top_values': {str(k): int(v) for k, v in value_counts.items()},
                'avg_length': round(df[col].astype(str).str.len().mean(), 2) if len(df[col].dropna()) > 0 else 0
            })

        profile['column_profiles'][col] = col_profile

    # Save profile
    profile_dir = Path("02_intermediate/022_profiled")
    profile_dir.mkdir(parents=True, exist_ok=True)
    profile_file = profile_dir / f"{filepath.stem}_profile.yaml"

    with open(profile_file, 'w') as f:
        yaml.dump(profile, f, default_flow_style=False)

    # Print summary
    print(f"\n📊 Dataset Profile:")
    print(f"   Shape: {df.shape}")
    print(f"   Memory: {profile['dataset_info']['memory_usage_mb']} MB")
    print(f"   Columns: {len(df.columns)}")

    print(f"\n📋 Column Summary:")
    for col, col_prof in profile['column_profiles'].items():
        print(f"   {col}: {col_prof['dtype']} ({col_prof['null_percentage']:.1f}% null, {col_prof['unique_count']} unique)")

    print(f"\n📄 Profile saved: {profile_file}")

quality-report path:
    #!/usr/bin/env python3
    import pandas as pd
    import yaml
    from pathlib import Path
    from datetime import datetime

    filepath = Path("{{path}}")

    if not filepath.exists():
        print(f"❌ File not found: {filepath}")
        exit(1)

    print(f"📋 Generating quality report: {filepath}")

    # Load validation and profile reports if they exist
    validation_file = Path("02_intermediate/021_validated") / f"{filepath.stem}_validation_report.yaml"
    profile_file = Path("02_intermediate/022_profiled") / f"{filepath.stem}_profile.yaml"

    report = {
        'filepath': str(filepath),
        'generated_at': datetime.now().isoformat(),
        'summary': {},
        'recommendations': []
    }

    if validation_file.exists():
        with open(validation_file, 'r') as f:
            validation_data = yaml.safe_load(f)
            report['validation'] = validation_data

    if profile_file.exists():
        with open(profile_file, 'r') as f:
            profile_data = yaml.safe_load(f)
            report['profile'] = profile_data

    # Generate recommendations based on findings
    if 'validation' in report:
        score = report['validation']['quality_metrics']['overall_score']
        if score < 70:
            report['recommendations'].append("Dataset quality is below acceptable threshold (70%). Consider data cleaning.")
        if report['validation']['quality_metrics']['completeness'] < 90:
            report['recommendations'].append("High missing data detected. Consider imputation strategies.")
        if report['validation']['quality_metrics']['uniqueness'] < 95:
            report['recommendations'].append("Duplicate records detected. Consider deduplication.")
        if report['validation']['issues']:
            report['recommendations'].append("Address data quality issues before proceeding to analysis.")

    # Generate HTML report
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Data Quality Report - {filepath.name}</title>
        <style>
            body {{ font-family: Arial, sans-serif }}
            body {{ margin: 40px }}
            .header {{ background: #f0f8ff }}
            .header {{ padding: 20px }}
            .header {{ border-radius: 5px }}
            .section {{ margin: 20px 0 }}
            .metric {{ display: inline-block }}
            .metric {{ margin: 10px }}
            .metric {{ padding: 15px }}
            .metric {{ background: #f9f9f9 }}
            .metric {{ border-radius: 5px }}
            .issue {{ color: #d32f2f }}
            .recommendation {{ color: #1976d2 }}
        </style>
    </head>
    <body>
        <div class="header">
            <h1>Data Quality Report</h1>
            <p><strong>Dataset:</strong> {filepath.name}</p>
            <p><strong>Generated:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        </div>
    """

    if 'validation' in report:
        metrics = report['validation']['quality_metrics']
        html_content += f"""
        <div class="section">
            <h2>Quality Metrics</h2>
            <div class="metric">
                <h3>Overall Score</h3>
                <p style="font-size: 24px; font-weight: bold;">{metrics['overall_score']}/100</p>
            </div>
            <div class="metric">
                <h3>Completeness</h3>
                <p>{metrics['completeness']:.1f}%</p>
            </div>
            <div class="metric">
                <h3>Uniqueness</h3>
                <p>{metrics['uniqueness']:.1f}%</p>
            </div>
            <div class="metric">
                <h3>Consistency</h3>
                <p>{metrics['consistency']:.1f}%</p>
            </div>
        </div>
        """

        if report['validation']['issues']:
            html_content += """
            <div class="section">
                <h2>Issues Found</h2>
                <ul>
            """
            for issue in report['validation']['issues']:
                html_content += f'<li class="issue">{issue}</li>'
            html_content += "</ul></div>"

    if report['recommendations']:
        html_content += """
        <div class="section">
            <h2>Recommendations</h2>
            <ul>
        """
        for rec in report['recommendations']:
            html_content += f'<li class="recommendation">{rec}</li>'
        html_content += "</ul></div>"

    html_content += "</body></html>"

    # Save reports
    report_dir = Path("08_reporting")
    report_dir.mkdir(parents=True, exist_ok=True)

    yaml_report_file = report_dir / f"{filepath.stem}_quality_report.yaml"
    html_report_file = report_dir / f"{filepath.stem}_quality_report.html"

    with open(yaml_report_file, 'w') as f:
        yaml.dump(report, f, default_flow_style=False)

    with open(html_report_file, 'w') as f:
        f.write(html_content)

    print(f"✅ Quality report generated")
    print(f"📄 YAML report: {yaml_report_file}")
    print(f"🌐 HTML report: {html_report_file}")

# Data Processing Workflows
clean-dataset source target:
    #!/usr/bin/env python3
    import pandas as pd
    import numpy as np
    import yaml
    from pathlib import Path
    from datetime import datetime

    source_path = Path("{{source}}")
    target_name = "{{target}}"
    timestamp = "{{DATE}}"

    if not source_path.exists():
        print(f"❌ Source file not found: {source_path}")
        exit(1)

    print(f"🧹 Cleaning dataset: {source_path}")

    # Load data
    try:
        if source_path.suffix.lower() == '.csv':
            df = pd.read_csv(source_path)
        elif source_path.suffix.lower() in ['.xlsx', '.xls']:
            df = pd.read_excel(source_path)
        else:
            print(f"❌ Unsupported file format: {source_path.suffix}")
            exit(1)
    except Exception as e:
        print(f"❌ Error loading file: {e}")
        exit(1)

    original_shape = df.shape
    cleaning_log = []

    # Remove duplicate rows
    duplicates_before = df.duplicated().sum()
    df = df.drop_duplicates()
    if duplicates_before > 0:
        cleaning_log.append(f"Removed {duplicates_before} duplicate rows")

    # Handle missing values (basic strategy)
    missing_before = df.isnull().sum().sum()
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    categorical_cols = df.select_dtypes(include=['object']).columns

    # Fill numeric columns with median
    for col in numeric_cols:
        if df[col].isnull().any():
            median_val = df[col].median()
            df[col].fillna(median_val, inplace=True)
            cleaning_log.append(f"Filled missing values in '{col}' with median ({median_val})")

    # Fill categorical columns with mode
    for col in categorical_cols:
        if df[col].isnull().any():
            mode_val = df[col].mode().iloc[0] if not df[col].mode().empty else 'Unknown'
            df[col].fillna(mode_val, inplace=True)
            cleaning_log.append(f"Filled missing values in '{col}' with mode ('{mode_val}')")

    missing_after = df.isnull().sum().sum()

    # Remove outliers using IQR method for numeric columns
    outliers_removed = 0
    for col in numeric_cols:
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1
        outlier_mask = (df[col] < Q1 - 1.5 * IQR) | (df[col] > Q3 + 1.5 * IQR)
        outliers_in_col = outlier_mask.sum()
        if outliers_in_col > 0:
            df = df[~outlier_mask]
            outliers_removed += outliers_in_col
            cleaning_log.append(f"Removed {outliers_in_col} outliers from '{col}'")

    # Save cleaned dataset
    target_dir = Path("02_intermediate/023_cleaned")
    target_dir.mkdir(parents=True, exist_ok=True)
    target_file = target_dir / f"{target_name}_cleaned_{timestamp}.csv"
    df.to_csv(target_file, index=False)

    # Create cleaning metadata
    metadata = {
        'source_file': str(source_path),
        'target_file': str(target_file),
        'cleaned_at': datetime.now().isoformat(),
        'original_shape': list(original_shape),
        'cleaned_shape': list(df.shape),
        'rows_removed': original_shape[0] - df.shape[0],
        'cleaning_operations': cleaning_log,
        'statistics': {
            'duplicates_removed': duplicates_before,
            'missing_values_before': missing_before,
            'missing_values_after': missing_after,
            'outliers_removed': outliers_removed
        }
    }

    metadata_file = target_dir / f"{target_name}_cleaned_{timestamp}.metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(metadata, f, default_flow_style=False)

    print(f"\n✅ Dataset cleaned successfully!")
    print(f"   Original shape: {original_shape}")
    print(f"   Cleaned shape: {df.shape}")
    print(f"   Rows removed: {original_shape[0] - df.shape[0]}")
    print(f"   Operations performed: {len(cleaning_log)}")

    if cleaning_log:
        print(f"\n🔧 Cleaning operations:")
        for operation in cleaning_log:
            print(f"   - {operation}")

    print(f"\n📄 Cleaned dataset: {target_file}")
    print(f"📄 Metadata: {metadata_file}")

split-dataset source target:
    #!/usr/bin/env python3
    import pandas as pd
    import numpy as np
    import yaml
    from pathlib import Path
    from datetime import datetime
    from sklearn.model_selection import train_test_split

    source_path = Path("{{source}}")
    target_name = "{{target}}"
    timestamp = "{{DATE}}"

    if not source_path.exists():
        print(f"❌ Source file not found: {source_path}")
        exit(1)

    print(f"🔄 Splitting dataset: {source_path}")

    # Load data
    try:
        df = pd.read_csv(source_path)
    except Exception as e:
        print(f"❌ Error loading file: {e}")
        exit(1)

    # Split ratios
    test_size = 0.2
    val_size = 0.2  # 20% of the remaining 80%

    # First split: separate test set
    train_val, test = train_test_split(df, test_size=test_size, random_state=42)

    # Second split: separate train and validation
    train, val = train_test_split(train_val, test_size=val_size, random_state=42)

    # Create output directories
    train_dir = Path("05_model_input/051_train")
    val_dir = Path("05_model_input/052_validation")
    test_dir = Path("05_model_input/053_test")

    for dir_path in [train_dir, val_dir, test_dir]:
        dir_path.mkdir(parents=True, exist_ok=True)

    # Save splits
    train_file = train_dir / f"{target_name}_train_{timestamp}.csv"
    val_file = val_dir / f"{target_name}_val_{timestamp}.csv"
    test_file = test_dir / f"{target_name}_test_{timestamp}.csv"

    train.to_csv(train_file, index=False)
    val.to_csv(val_file, index=False)
    test.to_csv(test_file, index=False)

    # Create split metadata
    metadata = {
        'source_file': str(source_path),
        'split_at': datetime.now().isoformat(),
        'original_shape': list(df.shape),
        'split_config': {
            'test_size': test_size,
            'val_size': val_size,
            'random_state': 42
        },
        'splits': {
            'train': {
                'file': str(train_file),
                'shape': list(train.shape),
                'percentage': round(len(train) / len(df) * 100, 1)
            },
            'validation': {
                'file': str(val_file),
                'shape': list(val.shape),
                'percentage': round(len(val) / len(df) * 100, 1)
            },
            'test': {
                'file': str(test_file),
                'shape': list(test.shape),
                'percentage': round(len(test) / len(df) * 100, 1)
            }
        }
    }

    # Save metadata in all directories
    for dir_path in [train_dir, val_dir, test_dir]:
        metadata_file = dir_path / f"{target_name}_split_{timestamp}.metadata.yaml"
        with open(metadata_file, 'w') as f:
            yaml.dump(metadata, f, default_flow_style=False)

    print(f"\n✅ Dataset split successfully!")
    print(f"   Original: {df.shape[0]} rows")
    print(f"   Train: {train.shape[0]} rows ({metadata['splits']['train']['percentage']}%)")
    print(f"   Validation: {val.shape[0]} rows ({metadata['splits']['validation']['percentage']}%)")
    print(f"   Test: {test.shape[0]} rows ({metadata['splits']['test']['percentage']}%)")

    print(f"\n📄 Split files:")
    print(f"   Train: {train_file}")
    print(f"   Validation: {val_file}")
    print(f"   Test: {test_file}")

# Registry Management
register-dataset name path type:
    #!/usr/bin/env python3
    import yaml
    from pathlib import Path
    from datetime import datetime

    name = "{{name}}"
    path = "{{path}}"
    dataset_type = "{{type}}"

    registry_file = Path("{{DATA_REGISTRY}}")

    # Load existing registry or create new
    if registry_file.exists():
        with open(registry_file, 'r') as f:
            registry = yaml.safe_load(f) or {'datasets': {}}
    else:
        registry = {'datasets': {}}

    # Add dataset entry
    registry['datasets'][name] = {
        'path': path,
        'type': dataset_type,
        'registered_at': datetime.now().isoformat(),
        'status': 'active'
    }

    # Update registry metadata
    registry['updated_at'] = datetime.now().isoformat()
    registry['total_datasets'] = len(registry['datasets'])

    # Save registry
    with open(registry_file, 'w') as f:
        yaml.dump(registry, f, default_flow_style=False)

    print(f"✅ Registered dataset '{name}' in registry")
    print(f"📄 Registry: {registry_file}")

list-datasets:
    #!/usr/bin/env python3
    import yaml
    from pathlib import Path

    registry_file = Path("{{DATA_REGISTRY}}")

    if not registry_file.exists():
        print("📝 No datasets registered yet. Use 'just data::register-dataset' to add datasets.")
        return

    with open(registry_file, 'r') as f:
        registry = yaml.safe_load(f)

    if not registry.get('datasets'):
        print("📝 No datasets in registry.")
        return

    print(f"📊 Registered Datasets ({len(registry['datasets'])} total)")
    print(f"📅 Last updated: {registry.get('updated_at', 'Unknown')}")
    print("")

    for name, info in registry['datasets'].items():
        print(f"🔹 {name}")
        print(f"   Type: {info['type']}")
        print(f"   Path: {info['path']}")
        print(f"   Status: {info['status']}")
        print(f"   Registered: {info['registered_at']}")
        print("")

# Backup & Versioning
backup-dataset path name:
    #!/usr/bin/env python3
    import shutil
    import hashlib
    import yaml
    from pathlib import Path
    from datetime import datetime

    source_path = Path("{{path}}")
    backup_name = "{{name}}"
    timestamp = "{{TIMESTAMP}}"

    if not source_path.exists():
        print(f"❌ Source file not found: {source_path}")
        exit(1)

    # Create backup directory
    backup_dir = Path("10_backups/timestamped")
    backup_dir.mkdir(parents=True, exist_ok=True)

    # Create backup filename
    backup_file = backup_dir / f"{backup_name}_{timestamp}{source_path.suffix}"

    # Copy file
    shutil.copy2(source_path, backup_file)

    # Calculate checksum
    with open(backup_file, 'rb') as f:
        checksum = hashlib.sha256(f.read()).hexdigest()

    # Create backup metadata
    metadata = {
        'backup_name': backup_name,
        'source_file': str(source_path),
        'backup_file': str(backup_file),
        'created_at': datetime.now().isoformat(),
        'checksum': checksum,
        'size_bytes': backup_file.stat().st_size
    }

    # Save metadata
    metadata_file = backup_dir / f"{backup_name}_{timestamp}.metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(metadata, f, default_flow_style=False)

    print(f"💾 Created backup: {backup_file}")
    print(f"📄 Metadata: {metadata_file}")
    print(f"🔒 Checksum: {checksum}")

# Academic Workflows
prepare-publication dataset paper_name:
    #!/usr/bin/env python3
    import shutil
    import yaml
    from pathlib import Path
    from datetime import datetime

    source_path = Path("{{dataset}}")
    paper_name = "{{paper_name}}"

    if not source_path.exists():
        print(f"❌ Source dataset not found: {source_path}")
        exit(1)

    # Create publication directory structure
    pub_dir = Path("12_publications") / paper_name
    datasets_dir = pub_dir / "datasets"
    metadata_dir = pub_dir / "metadata"

    for dir_path in [datasets_dir, metadata_dir]:
        dir_path.mkdir(parents=True, exist_ok=True)

    # Copy dataset
    target_file = datasets_dir / source_path.name
    shutil.copy2(source_path, target_file)

    # Create publication metadata
    pub_metadata = {
        'paper_name': paper_name,
        'dataset_file': str(target_file),
        'source_file': str(source_path),
        'prepared_at': datetime.now().isoformat(),
        'publication_info': {
            'title': f"Dataset for {paper_name}",
            'description': "Dataset prepared for academic publication",
            'license': "CC-BY-4.0",
            'citation': f"Please cite: {paper_name} dataset",
            'doi': "TBD - assign before publication"
        },
        'data_management': {
            'version': "1.0",
            'access_level': "public",
            'retention_period': "indefinite",
            'backup_location': "institutional_repository"
        }
    }

    # Save publication metadata
    metadata_file = metadata_dir / "publication_metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(pub_metadata, f, default_flow_style=False)

    # Create README
    readme_content = f"""# {paper_name} - Dataset

## Description
This dataset was prepared for the publication: {paper_name}

## Files
- `{target_file.name}`: Main dataset file

## Citation
Please cite this dataset as: {paper_name} dataset

## License
This dataset is released under CC-BY-4.0 license.

## Contact
[Add contact information]

## Preparation Date
{datetime.now().strftime('%Y-%m-%d')}
"""

    readme_file = pub_dir / "README.md"
    with open(readme_file, 'w') as f:
        f.write(readme_content)

    print(f"📚 Publication dataset prepared: {pub_dir}")
    print(f"📄 Dataset: {target_file}")
    print(f"📄 Metadata: {metadata_file}")
    print(f"📄 README: {readme_file}")
    print(f"\n⚠️  Remember to:")
    print(f"   - Update DOI before publication")
    print(f"   - Review and update citation information")
    print(f"   - Verify license terms")

add-benchmark name path:
    #!/usr/bin/env python3
    import shutil
    import yaml
    from pathlib import Path
    from datetime import datetime

    benchmark_name = "{{name}}"
    source_path = Path("{{path}}")

    if not source_path.exists():
        print(f"❌ Source file not found: {source_path}")
        exit(1)

    # Create benchmark directory
    benchmark_dir = Path("11_benchmarks/standard")
    benchmark_dir.mkdir(parents=True, exist_ok=True)

    # Copy benchmark dataset
    target_file = benchmark_dir / f"{benchmark_name}{source_path.suffix}"
    shutil.copy2(source_path, target_file)

    # Create benchmark metadata
    metadata = {
        'name': benchmark_name,
        'source_file': str(source_path),
        'benchmark_file': str(target_file),
        'added_at': datetime.now().isoformat(),
        'description': f"Standard benchmark dataset: {benchmark_name}",
        'usage': "Use for academic comparisons and reproducible research",
        'baseline_results': "TBD - run initial experiments"
    }

    # Save metadata
    metadata_file = benchmark_dir / f"{benchmark_name}.metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(metadata, f, default_flow_style=False)

    print(f"🎯 Added benchmark dataset: {target_file}")
    print(f"📄 Metadata: {metadata_file}")
    print(f"\n💡 Next steps:")
    print(f"   - Run baseline experiments")
    print(f"   - Document expected performance ranges")
    print(f"   - Add to benchmark registry")

setup-collaboration project_name:
    #!/usr/bin/env python3
    import yaml
    from pathlib import Path
    from datetime import datetime

    project_name = "{{project_name}}"

    # Create collaboration directory structure
    collab_dir = Path("14_collaboration") / project_name
    shared_dir = collab_dir / "shared"
    agreements_dir = collab_dir / "agreements"
    federated_dir = collab_dir / "federated"

    for dir_path in [shared_dir, agreements_dir, federated_dir]:
        dir_path.mkdir(parents=True, exist_ok=True)

    # Create collaboration metadata
    collab_metadata = {
        'project_name': project_name,
        'created_at': datetime.now().isoformat(),
        'structure': {
            'shared': "Datasets shared between institutions",
            'agreements': "Data sharing agreements and contracts",
            'federated': "Federated learning configurations"
        },
        'participants': [],
        'data_governance': {
            'access_control': "role_based",
            'encryption': "required",
            'audit_trail': "enabled"
        }
    }

    # Save metadata
    metadata_file = collab_dir / "collaboration_metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(collab_metadata, f, default_flow_style=False)

    # Create README
    readme_content = f"""# {project_name} - Collaboration Setup

## Directory Structure
- `shared/`: Datasets shared between participating institutions
- `agreements/`: Data sharing agreements and legal documents
- `federated/`: Federated learning configurations and models

## Getting Started
1. Add participating institutions to collaboration_metadata.yaml
2. Upload data sharing agreements to agreements/
3. Configure access controls and permissions
4. Set up federated learning environment if needed

## Data Governance
- All data transfers must be encrypted
- Access is role-based and logged
- Regular audits are required

## Created
{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""

    readme_file = collab_dir / "README.md"
    with open(readme_file, 'w') as f:
        f.write(readme_content)

    print(f"🤝 Collaboration setup created: {collab_dir}")
    print(f"📄 Metadata: {metadata_file}")
    print(f"📄 README: {readme_file}")
    print(f"\n📋 Next steps:")
    print(f"   - Add participant information")
    print(f"   - Upload data sharing agreements")
    print(f"   - Configure access controls")
    print(f"   - Set up federated learning if needed")

# === NEXTFLOW PIPELINE MANAGEMENT ===
# Single project-focused pipeline management with analysis organization

# Set pipeline name (stores in .pipeline_name file)
nextflow-set-pipeline name:
    #!/usr/bin/env python3
    from pathlib import Path
    
    name = "{{name}}"
    
    # Store pipeline name
    config_file = Path("15_pipelines/151_nextflow/.pipeline_name")
    config_file.parent.mkdir(parents=True, exist_ok=True)
    config_file.write_text(name.strip())
    
    print(f"✅ Pipeline name set to: {name}")
    print(f"📁 Stored in: {config_file}")

# Get current pipeline name
nextflow-get-pipeline:
    #!/usr/bin/env python3
    from pathlib import Path
    
    config_file = Path("15_pipelines/151_nextflow/.pipeline_name")
    
    if config_file.exists():
        name = config_file.read_text().strip()
        print(f"📋 Current pipeline: {name}")
    else:
        print("❌ No pipeline name set. Use: just data::nextflow-set-pipeline <name>")

# Run experiment with current pipeline
nextflow-run-experiment experiment dataset:
    #!/usr/bin/env python3
    import subprocess
    import yaml
    import json
    from pathlib import Path
    from datetime import datetime
    
    # Get current pipeline name
    config_file = Path("15_pipelines/151_nextflow/.pipeline_name")
    if not config_file.exists():
        print("❌ No pipeline name set. Use: just data::nextflow-set-pipeline <name>")
        exit(1)
    
    pipeline = config_file.read_text().strip()
    experiment = "{{experiment}}"
    dataset = "{{dataset}}"
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Create experiment directory - organized by analysis type
    exp_dir = Path(f"15_pipelines/151_nextflow/experiments/by_analysis/{experiment}")
    exp_dir.mkdir(parents=True, exist_ok=True)
    
    run_dir = exp_dir / f"{dataset}_{timestamp}"
    run_dir.mkdir(parents=True, exist_ok=True)
    
    work_dir = run_dir / "work"
    results_dir = run_dir / "results"
    logs_dir = run_dir / "logs"
    
    for d in [work_dir, results_dir, logs_dir]:
        d.mkdir(parents=True, exist_ok=True)
    
    # Check if pipeline exists
    pipeline_file = Path(f"15_pipelines/151_nextflow/pipelines/{pipeline}/workflow/main.nf")
    
    if not pipeline_file.exists():
        print(f"❌ Pipeline not found: {pipeline_file}")
        print(f"Available pipelines:")
        pipelines_dir = Path("15_pipelines/151_nextflow/pipelines")
        if pipelines_dir.exists():
            for p in pipelines_dir.glob("*/workflow/main.nf"):
                print(f"  - {p.parent.parent.name}")
        exit(1)
    
    # Nextflow command
    cmd = [
        "nextflow", "run", str(pipeline_file),
        "-work-dir", str(work_dir),
        "--outdir", str(results_dir),
        "--dataset", dataset,
        "--experiment", experiment,
        "-with-report", str(logs_dir / "report.html"),
        "-with-trace", str(logs_dir / "trace.txt"),
        "-with-timeline", str(logs_dir / "timeline.html"),
        "-with-dag", str(logs_dir / "dag.html")
    ]
    
    print(f"🚀 Running pipeline: {pipeline}")
    print(f"🔬 Analysis: {experiment}")
    print(f"📊 Dataset: {dataset}")
    print(f"📁 Results: {results_dir}")
    
    # Run pipeline
    try:
        result = subprocess.run(cmd, cwd=".", check=True)
        status = "SUCCESS"
        print(f"✅ Pipeline completed successfully!")
    except subprocess.CalledProcessError as e:
        status = "FAILED"
        print(f"❌ Pipeline failed: {e}")
    
    # Create experiment metadata
    metadata = {
        'pipeline': pipeline,
        'experiment': experiment,
        'dataset': dataset,
        'timestamp': timestamp,
        'status': status,
        'run_directory': str(run_dir),
        'results_directory': str(results_dir),
        'work_directory': str(work_dir),
        'command': ' '.join(cmd)
    }
    
    # Save metadata
    metadata_file = run_dir / "run_metadata.yaml"
    with open(metadata_file, 'w') as f:
        yaml.dump(metadata, f, default_flow_style=False)
    
    print(f"📄 Metadata saved: {metadata_file}")

# Run with specific pipeline (override current setting)
nextflow-run-with-pipeline pipeline experiment dataset:
    #!/usr/bin/env python3
    import subprocess
    import yaml
    from pathlib import Path
    from datetime import datetime
    
    pipeline = "{{pipeline}}"
    experiment = "{{experiment}}"
    dataset = "{{dataset}}"
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Create experiment directory
    exp_dir = Path(f"15_pipelines/151_nextflow/experiments/by_analysis/{experiment}")
    exp_dir.mkdir(parents=True, exist_ok=True)
    
    run_dir = exp_dir / f"{pipeline}_{dataset}_{timestamp}"
    run_dir.mkdir(parents=True, exist_ok=True)
    
    work_dir = run_dir / "work"
    results_dir = run_dir / "results"
    logs_dir = run_dir / "logs"
    
    for d in [work_dir, results_dir, logs_dir]:
        d.mkdir(parents=True, exist_ok=True)
    
    # Check if pipeline exists
    pipeline_file = Path(f"15_pipelines/151_nextflow/pipelines/{pipeline}/workflow/main.nf")
    
    if not pipeline_file.exists():
        print(f"❌ Pipeline not found: {pipeline_file}")
        exit(1)
    
    # Run with specific pipeline
    cmd = [
        "nextflow", "run", str(pipeline_file),
        "-work-dir", str(work_dir),
        "--outdir", str(results_dir),
        "--dataset", dataset,
        "--experiment", experiment,
        "-with-report", str(logs_dir / "report.html"),
        "-with-trace", str(logs_dir / "trace.txt"),
        "-with-timeline", str(logs_dir / "timeline.html"),
        "-with-dag", str(logs_dir / "dag.html")
    ]
    
    print(f"🚀 Running pipeline: {pipeline}")
    print(f"🔬 Analysis: {experiment}")
    print(f"📊 Dataset: {dataset}")
    
    try:
        subprocess.run(cmd, cwd=".", check=True)
        print(f"✅ Pipeline completed successfully!")
    except subprocess.CalledProcessError as e:
        print(f"❌ Pipeline failed: {e}")

# List all analyses (what used to be experiments)
nextflow-list-analyses:
    #!/usr/bin/env python3
    from pathlib import Path
    import yaml
    
    analyses_dir = Path("15_pipelines/151_nextflow/experiments/by_analysis")
    
    if not analyses_dir.exists():
        print("📝 No analyses found.")
        return
    
    print("🔬 Nextflow Analyses")
    print("=" * 40)
    
    for analysis_dir in analyses_dir.iterdir():
        if analysis_dir.is_dir():
            print(f"\n📁 {analysis_dir.name}")
            
            # Find all runs in this analysis
            runs = []
            for run_dir in analysis_dir.iterdir():
                if run_dir.is_dir():
                    metadata_file = run_dir / "run_metadata.yaml"
                    if metadata_file.exists():
                        with open(metadata_file, 'r') as f:
                            metadata = yaml.safe_load(f)
                            runs.append(metadata)
            
            # Sort by timestamp
            runs.sort(key=lambda x: x['timestamp'], reverse=True)
            
            for run in runs:
                status_icon = "✅" if run['status'] == "SUCCESS" else "❌"
                pipeline_name = run.get('pipeline', 'unknown')
                print(f"   {status_icon} {pipeline_name} - {run['dataset']} ({run['timestamp']})")

# List results for a specific analysis
nextflow-analysis-results analysis:
    #!/usr/bin/env python3
    from pathlib import Path
    import yaml
    
    analysis = "{{analysis}}"
    analysis_dir = Path(f"15_pipelines/151_nextflow/experiments/by_analysis/{analysis}")
    
    if not analysis_dir.exists():
        print(f"❌ Analysis not found: {analysis}")
        exit(1)
    
    print(f"📊 Results for analysis: {analysis}")
    print("=" * 50)
    
    for run_dir in analysis_dir.iterdir():
        if run_dir.is_dir():
            metadata_file = run_dir / "run_metadata.yaml"
            results_dir = run_dir / "results"
            
            if metadata_file.exists():
                with open(metadata_file, 'r') as f:
                    metadata = yaml.safe_load(f)
                
                pipeline = metadata.get('pipeline', 'unknown')
                print(f"\n🔬 {pipeline} - {metadata['dataset']}")
                print(f"   Time: {metadata['timestamp']}")
                print(f"   Status: {metadata['status']}")
                print(f"   Results: {results_dir}")
                
                # List result files
                if results_dir.exists():
                    result_files = list(results_dir.rglob("*"))
                    if result_files:
                        print(f"   Files: {len(result_files)} total")
                        for f in sorted(result_files)[:5]:  # Show first 5
                            if f.is_file():
                                size = f.stat().st_size
                                print(f"     - {f.name} ({size} bytes)")
                        if len(result_files) > 5:
                            print(f"     ... and {len(result_files) - 5} more files")

# Publish analysis results
nextflow-publish-analysis analysis run_id destination:
    #!/usr/bin/env python3
    import shutil
    import yaml
    from pathlib import Path
    from datetime import datetime
    
    analysis = "{{analysis}}"
    run_id = "{{run_id}}"  # timestamp or partial match
    destination = "{{destination}}"
    
    # Find the analysis run
    analysis_dir = Path(f"15_pipelines/151_nextflow/experiments/by_analysis/{analysis}")
    
    if not analysis_dir.exists():
        print(f"❌ Analysis not found: {analysis}")
        exit(1)
    
    # Find matching run
    matching_runs = []
    for run_dir in analysis_dir.iterdir():
        if run_id in run_dir.name:
            matching_runs.append(run_dir)
    
    if not matching_runs:
        print(f"❌ No runs found matching: {run_id}")
        print(f"Available runs in {analysis}:")
        for run_dir in analysis_dir.iterdir():
            print(f"  - {run_dir.name}")
        exit(1)
    
    if len(matching_runs) > 1:
        print(f"⚠️  Multiple runs found matching '{run_id}':")
        for i, run_dir in enumerate(matching_runs):
            print(f"   {i+1}. {run_dir.name}")
        choice = input("Enter choice (1-{}): ".format(len(matching_runs)))
        source_run = matching_runs[int(choice)-1]
    else:
        source_run = matching_runs[0]
    
    results_dir = source_run / "results"
    
    if not results_dir.exists():
        print(f"❌ No results found in: {results_dir}")
        exit(1)
    
    # Determine destination
    if destination == "primary":
        dest_dir = Path("03_primary/033_versioned") / f"nextflow_{analysis}_{run_id}"
    elif destination == "reporting":
        dest_dir = Path("08_reporting") / f"nextflow_{analysis}_{run_id}"
    elif destination == "publication":
        dest_dir = Path("12_publications/datasets") / f"nextflow_{analysis}_{run_id}"
    else:
        dest_dir = Path(destination) / f"nextflow_{analysis}_{run_id}"
    
    dest_dir.mkdir(parents=True, exist_ok=True)
    
    # Copy results
    print(f"📦 Publishing results from {analysis} analysis")
    print(f"   Source: {results_dir}")
    print(f"   Destination: {dest_dir}")
    
    for item in results_dir.rglob("*"):
        if item.is_file():
            rel_path = item.relative_to(results_dir)
            dest_file = dest_dir / rel_path
            dest_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(item, dest_file)
    
    # Copy metadata
    metadata_file = source_run / "run_metadata.yaml"
    if metadata_file.exists():
        shutil.copy2(metadata_file, dest_dir / "source_metadata.yaml")
    
    print(f"✅ Results published to: {dest_dir}")

# Clean old analysis work directories
nextflow-clean-work analysis days=7:
    #!/usr/bin/env python3
    import shutil
    from pathlib import Path
    import time
    
    analysis = "{{analysis}}"
    days = int("{{days}}")
    
    analysis_dir = Path(f"15_pipelines/151_nextflow/experiments/by_analysis/{analysis}")
    
    if not analysis_dir.exists():
        print(f"❌ Analysis not found: {analysis}")
        exit(1)
    
    cutoff_time = time.time() - (days * 24 * 3600)
    cleaned = 0
    
    for run_dir in analysis_dir.iterdir():
        if run_dir.is_dir():
            work_dir = run_dir / "work"
            if work_dir.exists() and work_dir.stat().st_mtime < cutoff_time:
                print(f"🧹 Cleaning work directory: {work_dir}")
                shutil.rmtree(work_dir)
                cleaned += 1
    
    print(f"✅ Cleaned {cleaned} work directories older than {days} days")

# Create a new pipeline template with current project focus
nextflow-create-pipeline pipeline_name:
    #!/usr/bin/env python3
    from pathlib import Path
    from datetime import datetime
    
    pipeline_name = "{{pipeline_name}}"
    pipeline_dir = Path(f"15_pipelines/151_nextflow/pipelines/{pipeline_name}")
    
    if pipeline_dir.exists():
        print(f"❌ Pipeline already exists: {pipeline_name}")
        exit(1)
    
    # Create pipeline structure
    workflow_dir = pipeline_dir / "workflow"
    workflow_dir.mkdir(parents=True, exist_ok=True)
    
    # Create basic workflow template
    main_nf = workflow_dir / "main.nf"
    main_nf.write_text(f'''#!/usr/bin/env nextflow

/*
 * {pipeline_name.title()} Pipeline
 * Created: {datetime.now().strftime("%Y-%m-%d")}
 * Project: Single Research Project Template
 */

nextflow.enable.dsl = 2

// Parameters
params.dataset = "example_dataset"
params.experiment = "analysis_name" 
params.outdir = "results"

// Input
input_ch = Channel.fromPath(params.dataset)

// Process
process MAIN_PROCESS {{
    publishDir "${{params.outdir}}", mode: 'copy'
    
    input:
    path input_file
    
    output:
    path "output.txt"
    
    script:
    """
    echo "Processing ${{input_file}} for analysis ${{params.experiment}}" > output.txt
    date >> output.txt
    """
}}

// Workflow
workflow {{
    MAIN_PROCESS(input_ch)
}}

workflow.onComplete {{
    println "Pipeline: {pipeline_name}"
    println "Analysis: ${{params.experiment}}"
    println "Dataset: ${{params.dataset}}" 
    println "Status: ${{workflow.success ? 'SUCCESS' : 'FAILED'}}"
    println "Duration: ${{workflow.duration}}"
}}
''')
    
    print(f"✅ Created pipeline: {pipeline_name}")
    print(f"📁 Location: {pipeline_dir}")
    print(f"📄 Edit workflow: {main_nf}")
    print(f"\nTo set as current pipeline:")
    print(f"just data::nextflow-set-pipeline {pipeline_name}")
    print(f"\nTo run:")
    print(f"just data::nextflow-run-experiment my_analysis my_dataset")
