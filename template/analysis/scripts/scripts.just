# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
script-nu-scratch:
    nushell/scratch.nu

script-ocaml-minimo:
    dune exec ocaml/minimo.exe

script-java-hello:
    jbang java/helloworld.java

script-go-hello:
    go run golang/hello.go

# Data validation
validate-data:
    python scripts/data/validate.py

# Train model
train:
    python scripts/train.py

# Evaluate model
evaluate:
    python scripts/evaluate.py

# Export model artifact
export-model:
    python scripts/export_model.py
