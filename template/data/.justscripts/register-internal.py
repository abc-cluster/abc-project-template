import os
import hashlib
import yaml
from datetime import datetime
from pathlib import Path
import shutil

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
