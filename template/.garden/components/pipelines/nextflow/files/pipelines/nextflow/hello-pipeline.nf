#!/usr/bin/env nextflow

/*
 * Simple hello world pipeline for testing investigation management
 * Based on nextflow-io/hello
 */

params.greeting = 'Hello'
params.name = 'World'

process sayHello {
    input:
    val greeting
    val name

    output:
    stdout

    script:
    """
    echo '$greeting $name!'
    sleep 2
    """
}

workflow {
    sayHello(params.greeting, params.name)
    sayHello.out.view()
}
