#!/bin/bash

# Demo script to generate all table variations
# This showcases the complete functionality of the pollen-qmd system

echo "🚀 Pollen-QMD Demo: Generating all table examples..."
echo ""

cd "$(dirname "$0")/.." || exit 1

# Ensure the shell script is executable
chmod +x generate-enhanced.sh

echo "📊 Generating Typst tables with different styles..."

# Generate three-line style
echo "  → Three-line style (academic)"
./generate-enhanced.sh typst three-line examples/table-typst-three-line.qmd
if [ $? -eq 0 ]; then
    echo "    ✅ Generated examples/table-typst-three-line.qmd"
else
    echo "    ❌ Failed to generate three-line table"
fi

# Generate bordered style  
echo "  → Bordered style (enhanced readability)"
./generate-enhanced.sh typst bordered examples/table-typst-bordered.qmd
if [ $? -eq 0 ]; then
    echo "    ✅ Generated examples/table-typst-bordered.qmd"
else
    echo "    ❌ Failed to generate bordered table"
fi

echo ""
echo "📝 Generating DOCX table..."

# Generate DOCX version
echo "  → DOCX format (Word compatible)"
./generate-enhanced.sh docx three-line examples/table-docx.qmd
if [ $? -eq 0 ]; then
    echo "    ✅ Generated examples/table-docx.qmd"
else
    echo "    ❌ Failed to generate DOCX table"
fi

echo ""
echo "🔍 Analyzing generated files..."

# Count generated files
typst_files=$(ls examples/table-typst-*.qmd 2>/dev/null | wc -l)
docx_files=$(ls examples/table-docx*.qmd 2>/dev/null | wc -l)
total_files=$((typst_files + docx_files))

echo "  📈 Generated $total_files QMD files:"
echo "    - $typst_files Typst files (PDF-ready)"
echo "    - $docx_files DOCX files (Word-ready)"

echo ""
echo "📋 File sizes and content preview:"

for file in examples/table-*.qmd; do
    if [ -f "$file" ]; then
        size=$(wc -l < "$file")
        echo "  📄 $(basename "$file"): $size lines"
        
        # Show first few lines of content
        echo "     Preview:"
        head -n 5 "$file" | sed 's/^/       │ /'
        echo "       │ ..."
        echo ""
    fi
done

echo "🎯 Data source information:"
echo "  📊 Using data from:"
if [ -f "data.csv" ]; then
    rows=$(tail -n +2 data.csv | wc -l)
    echo "    - data.csv ($rows data rows)"
fi
if [ -f "data.json" ]; then
    echo "    - data.json (available)"
fi
if [ -f "data.yaml" ]; then
    echo "    - data.yaml (available)"
fi

echo ""
echo "🎨 Template information:"
echo "  🎭 Available Typst styles:"
ls typst-templates/table-imports*.typ 2>/dev/null | while read -r file; do
    style=$(basename "$file" | sed 's/table-imports-//; s/table-imports//; s/\.typ//; s/^-//')
    if [ -z "$style" ]; then
        style="three-line"
    fi
    echo "    - $style ($(basename "$file"))"
done

echo ""
echo "📖 Content templates:"
ls content-templates/*.md 2>/dev/null | while read -r file; do
    echo "    - $(basename "$file")"
done

echo ""
echo "🚦 Next steps:"
echo ""
echo "  To render the generated tables:"
echo "    cd examples/"
echo "    quarto render table-typst-three-line.qmd --to typst    # → PDF"
echo "    quarto render table-typst-bordered.qmd --to typst      # → PDF"  
echo "    quarto render table-docx.qmd --to docx                 # → DOCX"
echo ""
echo "  To customize:"
echo "    1. Edit data.csv (or data.json/data.yaml) with your content"
echo "    2. Modify content-templates/table-1-heading.md for your title"
echo "    3. Run this script again to regenerate all examples"
echo ""
echo "✨ Demo completed! All examples generated successfully."