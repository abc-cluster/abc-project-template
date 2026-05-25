# tasks/_introspection.just — orientation helpers (Phase 5).
#
# Provides:
#   just doctor      — check tools/state for currently planted components
#   just tour        — 5-line orientation for current project state
#   just where X     — answer "where does X go in this project?"

# Print a guided orientation tailored to the planted state of this project.
[no-cd]
tour:
    @python3 .garden/garden.py status 2>/dev/null || echo "(.garden/ not present)"
    @echo ""
    @echo "Project layout:"
    @echo "  notebooks/   exploratory work"
    @echo "  data/        raw / intermediate / primary / reports"
    @echo "  src/         library code (importable)"
    @echo "  scripts/     operational scripts"
    @echo "  pipelines/   DVC + Nextflow + Snakemake"
    @echo "  tests/       test suite"
    @echo "  writeup/     manuscripts (other formats: just grow writeup:<name>)"
    @echo "  config/      project configs"
    @echo "  .garden/     dormant components (just garden-list dormant)"
    @echo ""
    @echo "Common commands:"
    @echo "  just garden                    — what's planted vs dormant"
    @echo "  just grow <component>          — plant a dormant component"
    @echo "  just prune <component>         — archive a planted component"
    @echo "  just where <thing>             — find where X lives in this project"
    @echo "  just doctor                    — environment health check"

# Health check: report on tools needed by currently planted components.
[no-cd]
doctor:
    #!/usr/bin/env bash
    set -e
    echo "==> Environment doctor"
    echo ""
    # Always-needed
    for tool in python3 just git copier; do
      if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✓ $tool: $(command -v "$tool")"
      else
        echo "  ✗ $tool: NOT FOUND"
      fi
    done
    echo ""
    # Optional, conditional on planted components
    if [ -f .garden/manifest.yaml ]; then
      echo "==> Planted components"
      python3 .garden/garden.py list planted 2>/dev/null | tail -n +2 | head -20
    fi
    # Tool-specific recommendations
    echo ""
    echo "==> Tool checks (per planted area)"
    if command -v dvc >/dev/null 2>&1 && [ -f dvc.yaml ]; then
      echo "  ✓ dvc + dvc.yaml present"
    fi
    if command -v pixi >/dev/null 2>&1 && [ -f pixi.toml ]; then
      echo "  ✓ pixi + pixi.toml present"
    fi
    if command -v Rscript >/dev/null 2>&1 && [ -f renv.lock ]; then
      echo "  ✓ Rscript + renv.lock present"
    fi
    if command -v nextflow >/dev/null 2>&1 && [ -d pipelines/nextflow ]; then
      echo "  ✓ nextflow + pipelines/nextflow planted"
    fi
    if command -v quarto >/dev/null 2>&1 && [ -d writeup/manuscript ]; then
      echo "  ✓ quarto + writeup/manuscript present"
    fi

# Find where a concept lives in this project.
[no-cd]
where thing:
    #!/usr/bin/env bash
    case "{{thing}}" in
      raw-data|raw)         echo "data/01_raw/" ;;
      intermediate|interm)  echo "data/02_intermediate/" ;;
      processed|primary)    echo "data/03_primary/" ;;
      features)             echo "data/features/  (component data:features — just grow if missing)" ;;
      models)               echo "data/models/    (component data:models — just grow if missing)" ;;
      results|reports)      echo "data/08_reporting/" ;;
      figures)              echo "data/08_reporting/082_figures/" ;;
      tables)               echo "data/08_reporting/081_tables/" ;;
      notebooks)            echo "notebooks/" ;;
      scripts)              echo "scripts/  (operational)" ;;
      src|code|library)     echo "src/      (importable library code)" ;;
      tests)                echo "tests/" ;;
      manuscript)           echo "writeup/manuscript/" ;;
      poster|posters)       echo "writeup/poster/   (component writeup:poster — just grow if missing)" ;;
      grants)               echo "writeup/grants/   (component writeup:grants — just grow if missing)" ;;
      presentation|slides)  echo "writeup/presentation/  (component writeup:presentation — just grow if missing)" ;;
      pipeline|pipelines)   echo "pipelines/" ;;
      config|configs)       echo "config/" ;;
      garden|seed)          echo ".garden/components/  (seed bank — just garden-list dormant)" ;;
      *)
        echo "(unknown: '{{thing}}')"
        echo ""
        echo "Try one of: raw-data, intermediate, processed, features, models,"
        echo "  results, figures, tables, notebooks, scripts, src, tests,"
        echo "  manuscript, poster, grants, presentation, pipeline, config, garden"
        ;;
    esac
