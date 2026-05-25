import pandas as pd
import sys

if len(sys.argv) != 2:
    print("Usage: python check_samples.py <samples.tsv>")
    sys.exit(1)

samples_file = sys.argv[1]
try:
    df = pd.read_csv(samples_file, sep='\t')
    print(f'✅ Sample file valid: {len(df)} samples')
    required_cols = ['sample_id']
    missing = [col for col in required_cols if col not in df.columns]
    if missing:
        print(f'⚠️  Missing columns: {missing}')
    else:
        print('✅ Required columns present')
except Exception as e:
    print(f'❌ Sample file error: {e}')
