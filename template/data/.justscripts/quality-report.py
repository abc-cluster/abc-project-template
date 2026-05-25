import pandas as pd
import yaml
from pathlib import Path
from datetime import datetime

filepath = Path("{{path}}")

if not filepath.exists():
    print(f"❌ File not found: {filepath}")
    exit(1)

print(f"📋 Generating quality report: {filepath}")

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

# Save reports
report_dir = Path("08_reporting")
report_dir.mkdir(parents=True, exist_ok=True)

yaml_report_file = report_dir / f"{filepath.stem}_quality_report.yaml"
with open(yaml_report_file, 'w') as f:
    yaml.dump(report, f, default_flow_style=False)

print(f"✅ Quality report generated")
print(f"📄 YAML report: {yaml_report_file}")
