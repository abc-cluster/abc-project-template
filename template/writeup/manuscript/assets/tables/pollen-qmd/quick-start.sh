#!/bin/bash

# Quick Start Script for Pollen-QMD
# This script helps new users test the system immediately

echo "🌟 Welcome to Pollen-QMD Quick Start!"
echo ""
echo "This script will test the system and generate sample tables for you."
echo ""

# Check requirements
echo "🔧 Checking requirements..."

if ! command -v racket &> /dev/null; then
    echo "❌ Racket is not installed. Please install Racket first."
    echo "   Visit: https://racket-lang.org/"
    exit 1
else
    echo "✅ Racket found: $(racket --version)"
fi

if ! command -v quarto &> /dev/null; then
    echo "❌ Quarto is not installed. Please install Quarto first."
    echo "   Visit: https://quarto.org/"
    exit 1
else
    echo "✅ Quarto found: $(quarto --version | head -n 1)"
fi

echo ""
echo "🚀 All requirements satisfied! Starting demonstration..."
echo ""

# Make scripts executable
chmod +x generate-enhanced.sh
chmod +x examples/generate-all-examples.sh

# Test basic functionality
echo "📊 Testing basic table generation..."

echo "  → Generating a simple Typst table..."
./generate-enhanced.sh typst three-line quick-test.qmd
if [ $? -eq 0 ]; then
    echo "    ✅ Generated quick-test.qmd"
    
    echo "  → Testing Quarto rendering..."
    quarto render quick-test.qmd --to typst --quiet
    if [ $? -eq 0 ]; then
        echo "    ✅ Successfully rendered to PDF!"
        if [ -f "quick-test.pdf" ]; then
            echo "    📄 Created: quick-test.pdf"
        fi
    else
        echo "    ⚠️  Rendering had issues, but QMD generation worked"
    fi
else
    echo "    ❌ Failed to generate table"
    exit 1
fi

echo ""
echo "📚 Generating all example variations..."

# Run the comprehensive demo
./examples/generate-all-examples.sh

echo ""
echo "🎉 Quick start completed successfully!"
echo ""
echo "📁 Files created:"
echo "  - quick-test.qmd (test file)"
echo "  - quick-test.pdf (rendered PDF, if successful)"  
echo "  - examples/table-*.qmd (various formats and styles)"
echo ""
echo "🎯 What to do next:"
echo ""
echo "1. 📖 Read the README.md for detailed documentation"
echo "2. 🔧 Edit data.csv with your own table data"
echo "3. ✏️  Modify content-templates/table-1-heading.md for your table title"
echo "4. 🚀 Generate your tables with:"
echo "     ./generate-enhanced.sh typst three-line my-table.qmd"
echo "     ./generate-enhanced.sh docx three-line my-table-docx.qmd"
echo "5. 📄 Render with Quarto:"
echo "     quarto render my-table.qmd --to typst     # → PDF"
echo "     quarto render my-table-docx.qmd --to docx # → DOCX"
echo ""
echo "💡 For help: ./generate-enhanced.sh (shows usage)"
echo ""
echo "Happy table generating! 📊✨"

# Clean up test file
if [ -f "quick-test.qmd" ]; then
    echo ""
    echo "🧹 Cleaning up test files..."
    rm -f quick-test.qmd quick-test.pdf quick-test.typ
    echo "   ✅ Test files removed"
fi