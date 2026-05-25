#!/bin/bash
# Build script for academic presentation

set -e

echo "Building academic presentation..."

# Clean up previous nested output
if [ -d "output/src" ]; then
    mv output/src/* output/ 2>/dev/null || true
    rm -rf output/src
fi

# Build RevealJS slides
echo "Building RevealJS slides..."
cd src && quarto render template-presentation.qmd --to revealjs --output-dir ../output && cd ..

# Build HTML document
echo "Building HTML document..."
cd src && quarto render template-presentation.qmd --to html --output-dir ../output && cd ..

# Build PDF (if possible)
echo "Attempting to build PDF..."
cd src && quarto render template-presentation.qmd --to pdf --output-dir ../output && cd .. || echo "PDF build failed (LaTeX not available?)"

echo "Build complete! Outputs available in:"
ls -la output/
