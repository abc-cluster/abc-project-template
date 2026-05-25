
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# OCaml Package Development Automation
# Tools for creating, testing, and building OCaml research libraries

# Create a new OCaml library package
create-ocaml-package name description="Research OCaml library":
    #!/usr/bin/env bash
    package_dir="ocaml/{{name}}"
    mkdir -p "${package_dir}"
    cd "${package_dir}"
    
    # Initialize Dune project
    dune init project "{{name}}"
    cd "{{name}}"
    
    # Create main library file
    cat > "src/{{name}}.ml" << 'EOF'
(* {{name}}: {{description}} *)

(* Utility functions for mathematical computation *)

let mean data =
    let sum = List.fold_left ( +. ) 0.0 data in
    sum /. float_of_int (List.length data)

let variance data =
    let m = mean data in
    let sum_sq_diff = List.fold_left (fun acc x -> acc +. (x -. m) ** 2.) 0.0 data in
    sum_sq_diff /. float_of_int (List.length data)

let stddev data =
    sqrt (variance data)

let min_max data =
    List.fold_left (fun (mn, mx) x -> (min mn x, max mx x)) (List.hd data, List.hd data) data

let median data =
    let sorted = List.sort compare data in
    let n = List.length sorted in
    if n mod 2 = 1 then List.nth sorted (n / 2)
    else (List.nth sorted (n/2 - 1) +. List.nth sorted (n/2)) /. 2.

(* Main analysis function that returns collected stats as a tuple *)
let analyze data =
    let count = List.length data in
    let m = mean data in
    let std = stddev data in
    let mn, mx = min_max data in
    let med = median data in
    (count, m, std, mn, mx, med)

(* Example usage *)
let () =
    let data = [1.; 2.; 3.; 4.; 5.] in
    let count, mean, std, mn, mx, med = analyze data in
    Printf.printf "Count: %d\nMean: %f\nStd Dev: %f\nMin: %f\nMax: %f\nMedian: %f\n"
        count mean std mn mx med
EOF

    # Update Dune file
    cat > "src/dune" << 'EOF'
(library
 (name {{name}})
 (public_name {{name}})
 (synopsis "{{description}}"))
EOF

    # Copy template files if available
    if [ -f "../../templates/ocaml-library/README.md" ]; then
        cp "../../templates/ocaml-library/README.md" README.md
    fi
    
    echo "📦 Created OCaml package: ${package_dir}"
    echo "📝 To get started:"
    echo "   cd ${package_dir}"
    echo "   dune build"
    echo "   dune exec ./bin/{{name}}.exe"

# Test an OCaml package
test-ocaml package:
    #!/usr/bin/env bash
    if [ -d "ocaml/{{package}}" ]; then
        cd "ocaml/{{package}}"
        dune runtest
    else
        echo "❌ Package not found: ocaml/{{package}}"
        exit 1
    fi

# Build an OCaml package
build-ocaml package:
    #!/usr/bin/env bash
    if [ -d "ocaml/{{package}}" ]; then
        cd "ocaml/{{package}}"
        dune build
    else
        echo "❌ Package not found: ocaml/{{package}}"
        exit 1
    fi

# Run OCaml package example
run-ocaml-example package:
    #!/usr/bin/env bash
    if [ -d "ocaml/{{package}}" ]; then
        cd "ocaml/{{package}}"
        dune exec ./bin/{{package}}.exe
    else
        echo "❌ Package not found: ocaml/{{package}}"
        exit 1
    fi

# Clean OCaml package build artifacts
clean-ocaml package:
    #!/usr/bin/env bash
    if [ -d "ocaml/{{package}}" ]; then
        cd "ocaml/{{package}}"
        dune clean
    else
        echo "⚠️  No build artifacts to clean for ocaml/{{package}}"
    fi
