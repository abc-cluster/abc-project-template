#!/usr/bin/env bash
# Script to add shell platform selection to all justfiles
# This adds the shell configuration variables at the top of each justfile

set -eo pipefail

# Shell configuration header to add
SHELL_CONFIG="# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == \"windows\" { \"powershell\" } else { \"bash\" })
SCRIPT_EXT := if SHELL_TYPE == \"powershell\" { \"ps1\" } else { \"sh\" }
SHELL_CMD := if SHELL_TYPE == \"powershell\" { \"pwsh\" } else { \"bash\" }

"

# Find all justfiles, excluding certain paths
JUSTFILES=$(find . -type f \( -name "*.just" -o -name "justfile" \) \
    | grep -v ".pixi" \
    | grep -v "node_modules" \
    | sort)

# Counter
COUNT=0
SKIPPED=0
UPDATED=0

echo "🔍 Found justfiles to update:"
echo "$JUSTFILES" | sed 's/^\.\//  - /'
echo ""

# Process each justfile
for file in $JUSTFILES; do
    ((COUNT++))
    
    # Check if already has shell configuration
    if grep -q "SHELL_TYPE :=" "$file"; then
        echo "⏭️  Skipping $file (already has shell configuration)"
        ((SKIPPED++))
        continue
    fi
    
    echo "✏️  Updating $file..."
    
    # Create backup
    cp "$file" "$file.bak"
    
    # Add shell configuration at the top
    echo "$SHELL_CONFIG" | cat - "$file" > "$file.tmp"
    mv "$file.tmp" "$file"
    
    # Remove backup if successful
    rm "$file.bak"
    
    ((UPDATED++))
done

echo ""
echo "✅ Update complete!"
echo "   Total files: $COUNT"
echo "   Updated: $UPDATED"
echo "   Skipped: $SKIPPED"
