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

total_cells = df.shape[0] * df.shape[1]
missing_cells = df.isnull().sum().sum()
completeness = ((total_cells - missing_cells) / total_cells) * 100 if total_cells > 0 else 0
validation_results['quality_metrics']['completeness'] = round(completeness, 2)

duplicate_rows = df.duplicated().sum()
uniqueness = ((df.shape[0] - duplicate_rows) / df.shape[0]) * 100 if df.shape[0] > 0 else 0
validation_results['quality_metrics']['uniqueness'] = round(uniqueness, 2)

consistency_issues = 0
for col in df.columns:
    if df[col].dtype == 'object':
        non_null_values = df[col].dropna()
        if len(non_null_values) > 0:
            first_type = type(non_null_values.iloc[0])
            mixed_types = any(type(val) != first_type for val in non_null_values)
            if mixed_types:
                consistency_issues += 1
                validation_results['issues'].append(f"Mixed data types in column '{col}'")

consistency = ((len(df.columns) - consistency_issues) / len(df.columns)) * 100 if len(df.columns) > 0 else 0
validation_results['quality_metrics']['consistency'] = round(consistency, 2)

overall_score = (completeness + uniqueness + consistency) / 3
validation_results['quality_metrics']['overall_score'] = round(overall_score, 2)

if missing_cells > 0:
    validation_results['issues'].append(f"Missing values: {missing_cells} cells ({missing_cells/total_cells*100:.1f}%)")

if duplicate_rows > 0:
    validation_results['issues'].append(f"Duplicate rows: {duplicate_rows}")

numeric_cols = df.select_dtypes(include=[np.number]).columns
for col in numeric_cols:
    Q1 = df[col].quantile(0.25)
    Q3 = df[col].quantile(0.75)
    IQR = Q3 - Q1
    outliers = df[(df[col] < Q1 - 1.5 * IQR) | (df[col] > Q3 + 1.5 * IQR)][col].count()
    if outliers > 0:
        validation_results['issues'].append(f"Outliers in '{col}': {outliers} values")

report_dir = Path("02_intermediate/021_validated")
report_dir.mkdir(parents=True, exist_ok=True)
report_file = report_dir / f"{filepath.stem}_validation_report.yaml"

with open(report_file, 'w') as f:
    yaml.dump(validation_results, f, default_flow_style=False)

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
