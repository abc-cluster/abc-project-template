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
