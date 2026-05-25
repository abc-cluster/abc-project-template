# === Default Task ===

default:
    @just --list

#====== POWERSHELL =======

shebang := if os() == 'windows' {
  'powershell.exe'
} else {
  '/usr/local/bin/pwsh -NoProfile -c'
}

# === Rendering and Preview ===

manuscript-render-docx:
    quarto render src/index.qmd --to apaquarto-docx --output-dir _output/draft

manuscript-render-typst:
    #!{{shebang}}
    quarto render src/index.qmd --to apaquarto-typst --output-dir _output/draft

manuscript-preview-html:
    quarto preview src/index.qmd --to apaquarto-html

manuscript-render: manuscript-render-docx manuscript-render-typst

manuscript-clean:
    #!{{shebang}}
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue src/_book, src/index_files, _output

# === Compilation ===
manuscript-compile: manuscript-render-typst
    #!{{shebang}}
    # Generate PDF from Typst
    $possibleTypstFiles = @("_output/draft/src/index.typ", "_output/draft/index.typ")
    $typstFile = $possibleTypstFiles | Where-Object { Test-Path $_ } | Select-Object -First 1
    $pdfFile = "_output/draft/index.pdf"

    if (-not $typstFile) {
        Write-Host "Error: typst file not found in expected locations:" -ForegroundColor Red
        $possibleTypstFiles | ForEach-Object { Write-Host "  - $_" }
        Write-Host "Available index.typ candidates:" -ForegroundColor Yellow
        Get-ChildItem -Path _output/draft -Recurse -Filter index.typ -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  - $($_.FullName)" }
        exit 1
    }

    # Quarto includes typst support, so no standalone typst binary is required.
    quarto typst compile $typstFile $pdfFile
    Write-Host "Compiled draft PDF from quarto typst: $pdfFile"

# === Versioning ===
manuscript-new-version version: manuscript-render manuscript-compile
    #!{{shebang}}
    $version = "{{version}}"
    $versionName = "v$version-$(Get-Date -Format 'yyyy-MM-ddTHH-mm-ss')"
    $versionDir = "versions/$versionName"

    # Archive under versions (exclude _extensions folder)
    New-Item -ItemType Directory -Force -Path "$versionDir/feedback" | Out-Null
    Write-Host "Created version folder: $versionDir"

    if (Test-Path "_output/draft") {
        Copy-Item -Recurse -Force -Path "_output/draft/*" -Destination "$versionDir" -ErrorAction SilentlyContinue
        if (Test-Path "$versionDir/_extensions") {
            Remove-Item -Recurse -Force "$versionDir/_extensions" -ErrorAction SilentlyContinue
        }

        # Keep only src/index.pdf and remove top-level PDF duplicates
        Remove-Item -Force -ErrorAction SilentlyContinue "$versionDir/index.pdf","$versionDir/manuscript.pdf"
        Write-Host "Copied draft output into $versionDir (excluding _extensions) and removed top-level PDF duplicates"
    } else {
        Write-Host "Warning: _output/draft not found; please run manuscript-compile first."
    }

    # Copy source markdown, bibliography, metadata for reproducibility
    if (Test-Path "src/index.qmd") {
        Copy-Item -Force "src/index.qmd" -Destination "$versionDir/index.qmd" -ErrorAction SilentlyContinue
    }
    if (Test-Path "src/references.bib") {
        Copy-Item -Force "src/references.bib" -Destination "$versionDir/references.bib" -ErrorAction SilentlyContinue
    }
    if (Test-Path "src/_metadata.yml") {
        Copy-Item -Force "src/_metadata.yml" -Destination "$versionDir/_metadata.yml" -ErrorAction SilentlyContinue
    }

    # Ensure files from version/src are at root level
    if (Test-Path "$versionDir/src") {
        Copy-Item -Recurse -Force -Path "$versionDir/src/*" -Destination "$versionDir" -ErrorAction SilentlyContinue
        Remove-Item -Recurse -Force "$versionDir/src" -ErrorAction SilentlyContinue
        Write-Host "Moved files from $versionDir/src to $versionDir top-level"
    }

    Write-Host "Rendered and archived version (quarto, typst, pdf) to: $versionDir"

# === Misc ===

preprint-prepare version_name target_folder:
    #!{{shebang}}
    $versionInput = "{{version_name}}"
    $targetDir = "submissions/preprints/{{target_folder}}"

    # Accept either exact folder name or semver expected as version shorthand
    if (Test-Path "versions/$versionInput") {
        $sourceDir = "versions/$versionInput"
    } else {
        $matches = Get-ChildItem -Path versions -Directory -Filter "v$versionInput-*" | Sort-Object Name -Descending
        if ($matches.Count -eq 0) {
            Write-Host "Error: source version folder not found: versions/$versionInput or versions/v$versionInput-*" -ForegroundColor Red
            exit 1
        }
        $sourceDir = $matches[0].FullName
    }

    $sourceLeaf = Split-Path -Leaf $sourceDir
    $targetDirFull = "submissions/preprints/{{target_folder}}/$sourceLeaf"

    New-Item -ItemType Directory -Force -Path $targetDirFull | Out-Null
    Copy-Item -Recurse -Force -Path "$sourceDir/*" -Destination $targetDirFull -ErrorAction Stop
    Write-Host "Prepared preprint in: $targetDirFull (from $sourceDir)"

manuscript-docs:
    Write-Host "Manuscript Workflow:`n"
    Write-Host "1. Compile draft: just manuscript-compile"
    Write-Host "2. Render draft docx/typst: just manuscript-render"
    Write-Host "3. Build and archive version: just manuscript-build-all"
    Write-Host "4. Archive version manually: just manuscript-render-version version=<name>"
    Write-Host "5. Restore from version: just manuscript-restore-version version=<name>"
    Write-Host "6. Prepare preprint from version: just preprint-prepare version_name <platform>"
