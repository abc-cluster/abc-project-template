#!/bin/bash

# Multi-Table System Demo Script
echo "🚀 Multi-Table QMD Generator Demo"
echo "=================================="

# Set colors for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: List available tables
echo -e "\n${BLUE}📋 Step 1: List Available Tables${NC}"
echo "Command: ./generate-tables.sh list"
./generate-tables.sh list

# Step 2: Generate table-1 with different formats and styles
echo -e "\n${BLUE}📊 Step 2: Generate Software Features Table${NC}"
echo "Generating table-1 with Typst three-line style..."
racket generate-multi-table-simple.rkt --table table-1 --format typst --style three-line

echo -e "\n${GREEN}✓ Generated:${NC} features-table-typst-three-line.qmd"

# Step 3: Generate table-2 with custom performance style
echo -e "\n${BLUE}🔥 Step 3: Generate Performance Metrics Table${NC}"
echo "Generating table-2 with Typst bordered style (uses custom performance-table function)..."
racket generate-multi-table-simple.rkt --table table-2 --format typst --style bordered

echo -e "\n${GREEN}✓ Generated:${NC} performance-comparison-typst-bordered.qmd"

# Step 4: Show the directory structure
echo -e "\n${BLUE}📁 Step 4: Multi-Table Directory Structure${NC}"
echo "Tree view of the tables/ directory:"
if command -v tree >/dev/null 2>&1; then
    tree tables/ -L 3
else
    find tables/ -type d | head -20 | sed 's/^/  /'
fi

# Step 5: Show generated file content preview
echo -e "\n${BLUE}📄 Step 5: Generated File Preview${NC}"
if [ -f "features-table-typst-three-line.qmd" ]; then
    echo -e "\n${YELLOW}Preview of features-table-typst-three-line.qmd:${NC}"
    head -20 features-table-typst-three-line.qmd
fi

# Step 6: Show configuration example
echo -e "\n${BLUE}⚙️  Step 6: Table Configuration Example${NC}"
echo -e "\n${YELLOW}Sample config for table-1:${NC}"
head -30 tables/table-1/metadata/config.yaml

# Step 7: Demonstrate table creation
echo -e "\n${BLUE}🆕 Step 7: Create New Table Demo${NC}"
echo "Creating a demo table called 'demo-table'..."
./generate-tables.sh create demo-table

echo -e "\n${GREEN}✓ Created:${NC} tables/demo-table/ with template files"

# Step 8: Clean up demo table
echo -e "\n${BLUE}🧹 Step 8: Cleanup${NC}"
echo "Removing demo table..."
rm -rf tables/demo-table/

echo -e "\n${GREEN}✅ Demo Complete!${NC}"
echo -e "\n${YELLOW}What you've learned:${NC}"
echo "• How to list available tables"
echo "• How to generate tables with different styles"
echo "• The multi-table directory structure"
echo "• Configuration file format"
echo "• Table creation process"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "• Customize table configurations in tables/*/metadata/config.yaml"
echo "• Add your own data in tables/*/data/"
echo "• Create custom templates in tables/*/templates/"
echo "• Use Quarto to render QMD files to PDF/DOCX"

echo -e "\n${BLUE}For more details, see:${NC}"
echo "• MULTI-TABLE-README.md"
echo "• Individual table config files in tables/*/metadata/"