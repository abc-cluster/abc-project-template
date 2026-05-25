# Quarto tasks — reproducible document rendering
# Planted by: just grow writeup:quarto

# Render the entire Quarto project
quarto-render:
    quarto render

# Preview with live-reload in browser
quarto-preview:
    quarto preview

# Render a single file (usage: just quarto-file notebooks/my-notebook.qmd)
quarto-file file:
    quarto render "{{file}}"

# Check Quarto install and project config
quarto-check:
    @quarto check
    @echo ""
    @echo "Quarto project config:"
    @cat _quarto.yml

# Publish to Quarto Pub (requires: quarto publish setup)
quarto-publish:
    quarto publish

# Clean rendered output
quarto-clean:
    @rm -rf _output
    @echo "Cleaned _output/"
