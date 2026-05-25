# TODO: Explore distribution via bazel instead of jreleaser
# https://github.com/typedb/bazel-distribution#assemble_pip

py_library(
    name = "my_package",
    srcs = glob(["my_package/src/**/*.py"]),
    visibility = ["//visibility:public"],
)

py_test(
    name = "my_package_test",
    srcs = glob(["my_package/tests/**/*.py"]),
    main = "my_package/tests/core_test.py", 
    deps = [":my_package"],
    imports = ["."],  
)