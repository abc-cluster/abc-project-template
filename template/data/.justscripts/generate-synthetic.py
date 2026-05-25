import pandas as pd
import numpy as np
import yaml
from datetime import datetime
from pathlib import Path

name = "{{name}}"
data_type = "{{type}}"
size = int("{{size}}")
timestamp = "{{DATE}}"

target_dir = Path("01_raw/013_synthetic")
target_dir.mkdir(parents=True, exist_ok=True)

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

filename = f"{name}_{data_type}_{timestamp}.csv"
filepath = target_dir / filename
df.to_csv(filepath, index=False)

metadata = {
    'name': name,
    'type': data_type,
    'size': size,
    'generated_at': datetime.now().isoformat(),
    'filepath': str(filepath),
    'columns': list(df.columns),
    'shape': list(df.shape)
}

metadata_file = target_dir / f"{filename}.metadata.yaml"
with open(metadata_file, 'w') as f:
    yaml.dump(metadata, f, default_flow_style=False)

print(f"✅ Generated synthetic {data_type} dataset: {filepath}")
print(f"📊 Shape: {df.shape}")
print(f"📄 Metadata saved: {metadata_file}")
