import os
import urllib.request
import hashlib
import yaml
from datetime import datetime
from pathlib import Path

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
