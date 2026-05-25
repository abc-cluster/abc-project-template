import pandas as pd
import numpy as np
import yaml
from pathlib import Path
from datetime import datetime

filepath = Path("{{path}}")

if not filepath.exists():
    print(f"❌ File not found: {filepath}")
    exit(1)

print(f"📈 Profiling dataset: {filepath}")

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

for col in df.columns:
    col_profile = {
        'dtype': str(df[col].dtype),
        'null_count': int(df[col].isnull().sum()),
        'null_percentage': round(df[col].isnull().sum() / len(df) * 100, 2),
        'unique_count': int(df[col].nunique()),
        'unique_percentage': round(df[col].nunique() / len(df) * 100, 2)
    }

    if df[col].dtype in ['int64', 'float64', 'int32', 'float32']:
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
        value_counts = df[col].value_counts().head(10)
        col_profile.update({
            'top_values': {str(k): int(v) for k, v in value_counts.items()},
            'avg_length': round(df[col].astype(str).str.len().mean(), 2) if len(df[col].dropna()) > 0 else 0
        })

    profile['column_profiles'][col] = col_profile

profile_dir = Path("02_intermediate/022_profiled")
profile_dir.mkdir(parents=True, exist_ok=True)
profile_file = profile_dir / f"{filepath.stem}_profile.yaml"

with open(profile_file, 'w') as f:
    yaml.dump(profile, f, default_flow_style=False)

print(f"\n📊 Dataset Profile:")
print(f"   Shape: {df.shape}")
print(f"   Memory: {profile['dataset_info']['memory_usage_mb']} MB")
print(f"   Columns: {len(df.columns)}")

print(f"\n📋 Column Summary:")
for col, col_prof in profile['column_profiles'].items():
    print(f"   {col}: {col_prof['dtype']} ({col_prof['null_percentage']:.1f}% null, {col_prof['unique_count']} unique)")

print(f"\n📄 Profile saved: {profile_file}")
