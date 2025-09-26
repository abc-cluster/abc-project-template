#!/bin/bash

# Enhanced QMD Generator Shell Wrapper
# Supports external templates and style selection
# Usage: ./generate-enhanced.sh <format> <style> <output-file>
# Example: ./generate-enhanced.sh typst three-line table.qmd

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <format> <style> [output-file]"
    echo ""
    echo "Formats: typst, docx"
    echo "Styles:  three-line, bordered (typst only)"
    echo ""
    echo "Examples:"
    echo "  $0 typst three-line table.qmd"
    echo "  $0 typst bordered table-bordered.qmd"
    echo "  $0 docx three-line table-docx.qmd"
    exit 1
fi

FORMAT=$1
STYLE=$2
OUTPUT=${3:-"table-${FORMAT}-${STYLE}.qmd"}

echo "Generating QMD file: $OUTPUT"
echo "Format: $FORMAT"
echo "Style: $STYLE"
echo ""

racket generate-enhanced.rkt --format "$FORMAT" --style "$STYLE" --output "$OUTPUT"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully generated $OUTPUT"
    echo ""
    echo "To render:"
    if [ "$FORMAT" = "typst" ]; then
        echo "  quarto render $OUTPUT --to typst"
    else
        echo "  quarto render $OUTPUT --to docx"
    fi
else
    echo "❌ Generation failed"
    exit 1
fi