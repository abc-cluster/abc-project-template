#!/bin/bash

# Multi-table generation wrapper script
# Usage: ./generate-tables.sh [options]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATOR="$SCRIPT_DIR/generate-multi-table.rkt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}Multi-Table Generator${NC}"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo -e "${GREEN}Commands:${NC}"
    echo "  list                    List all available tables"
    echo "  generate TABLE_ID       Generate a specific table"
    echo "  batch                   Generate all tables"
    echo "  create TABLE_ID         Create a new table template"
    echo ""
    echo -e "${GREEN}Options (for generate command):${NC}"
    echo "  -f, --format FORMAT     Output format (typst or docx) [default: typst]"
    echo "  -s, --style STYLE       Table style (three-line or bordered) [default: three-line]"
    echo "  -o, --output FILE       Output filename [auto-generated if not specified]"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo "  $0 list"
    echo "  $0 generate table-1"
    echo "  $0 generate table-1 -f docx"
    echo "  $0 generate table-2 -s bordered -o my-performance.qmd"
    echo "  $0 batch"
    echo "  $0 create table-4"
}

# Function to list tables
list_tables() {
    echo -e "${BLUE}Listing available tables...${NC}"
    racket "$GENERATOR" --list
}

# Function to generate a specific table
generate_table() {
    local table_id="$1"
    shift
    
    if [ -z "$table_id" ]; then
        echo -e "${RED}Error: Table ID required${NC}"
        show_usage
        exit 1
    fi
    
    echo -e "${BLUE}Generating table: ${YELLOW}$table_id${NC}"
    racket "$GENERATOR" --table "$table_id" "$@"
}

# Function to batch generate all tables
batch_generate() {
    echo -e "${BLUE}Batch generating all tables...${NC}"
    racket "$GENERATOR" --batch
}

# Function to create a new table template
create_table() {
    local table_id="$1"
    
    if [ -z "$table_id" ]; then
        echo -e "${RED}Error: Table ID required${NC}"
        show_usage
        exit 1
    fi
    
    local table_dir="tables/$table_id"
    
    if [ -d "$table_dir" ]; then
        echo -e "${RED}Error: Table $table_id already exists${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Creating new table: ${YELLOW}$table_id${NC}"
    
    # Create directory structure
    mkdir -p "$table_dir"/{data,templates/{typst,content},metadata}
    
    # Create basic config file
    cat > "$table_dir/metadata/config.yaml" << EOF
---
# Table Configuration Metadata
table_id: $table_id
title: "New Table Title"
description: "Description of this table"
version: "1.0"
author: "Your Name"
created: "$(date +%Y-%m-%d)"
updated: "$(date +%Y-%m-%d)"

# Data Configuration
data:
  source_file: "data.json"
  format: "json"
  
  columns:
    - name: "column1"
      display_name: "Column 1"
      type: "string"
      description: "First column description"
    - name: "column2"
      display_name: "Column 2"
      type: "string"
      description: "Second column description"

# Template Configuration
templates:
  typst:
    custom_imports: null
    custom_functions: null
  content:
    heading: "heading.md"
    
# Style Configuration  
styles:
  default: "three-line"
  available: ["three-line", "bordered"]
  
# Output Configuration
output:
  filename_prefix: "$table_id"
  formats:
    typst:
      enabled: true
      styles: ["three-line", "bordered"]
    docx: 
      enabled: true
      
# Custom Settings
settings:
  typst:
    font_size: "10pt"
    column_widths: ["50%", "50%"]
    alternating_rows: true
  docx:
    table_style: "light_grid"
    
# Academic metadata
academic:
  label: "tbl-$table_id"
  caption: "Caption for $table_id"
  short_caption: "Short caption"
  placement: "here"
  
dependencies:
  shared_templates: true
  external_data: false
EOF
    
    # Create sample data file
    cat > "$table_dir/data/data.json" << EOF
[
  {
    "column1": "Sample value 1",
    "column2": "Sample value 2"
  },
  {
    "column1": "Another value 1",
    "column2": "Another value 2"
  }
]
EOF
    
    # Create sample heading template
    cat > "$table_dir/templates/content/heading.md" << EOF
# $table_id Title

Description and context for this table goes here.
EOF
    
    echo -e "${GREEN}✓ Created table structure for $table_id${NC}"
    echo -e "  Directory: $table_dir"
    echo -e "  Config:    $table_dir/metadata/config.yaml"
    echo -e "  Data:      $table_dir/data/data.json"
    echo -e "  Template:  $table_dir/templates/content/heading.md"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Edit the config file to match your requirements"
    echo -e "  2. Update the data file with your actual data"
    echo -e "  3. Customize the heading template"
    echo -e "  4. Generate the table: $0 generate $table_id"
}

# Parse command line arguments
case "$1" in
    "list")
        list_tables
        ;;
    "generate")
        shift
        generate_table "$@"
        ;;
    "batch")
        batch_generate
        ;;
    "create")
        shift
        create_table "$@"
        ;;
    "")
        show_usage
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        show_usage
        exit 1
        ;;
esac