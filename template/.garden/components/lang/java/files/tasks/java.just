
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Java Package Development Automation
# Tools for creating, testing, and building Java research libraries

# Create a new Java library package
create-java-package name description="Research Java library":
    #!/usr/bin/env bash
    package_dir="java/{{name}}"
    mkdir -p "${package_dir}"
    
    # Create Java project structure using Maven
    mvn archetype:generate -DgroupId="com.example" -DartifactId="{{name}}" -DarchetypeArtifactId="maven-archetype-quickstart" -DinteractiveMode="false" -Dpackage="com.example"
    
    mv "{{name}}" "${package_dir}"
    
    # Copy template files
    if [ -f "templates/java-library/README.md" ]; then
        cp "templates/java-library/README.md" "${package_dir}/README.md"
    fi
    
    echo "📦 Created Java package: ${package_dir}"
    echo "📝 To get started:"
    echo "   cd ${package_dir}"
    echo "   mvn clean compile"
    echo "   mvn test"
    echo "   mvn package"

# Test a Java package
test-java package:
    #!/usr/bin/env bash
    if [ -d "java/{{package}}" ]; then
        cd "java/{{package}}"
        mvn test
    else
        echo "❌ Package not found: java/{{package}}"
        exit 1
    fi

# Build a Java package
build-java package:
    #!/usr/bin/env bash
    if [ -d "java/{{package}}" ]; then
        cd "java/{{package}}"
        mvn package
    else
        echo "❌ Package not found: java/{{package}}"
        exit 1
    fi
