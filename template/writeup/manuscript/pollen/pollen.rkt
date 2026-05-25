#lang racket

(require yaml)
(require racket/file)

;; Setup for different output formats
(module setup racket/base
  (provide (all-defined-out))
  (define poly-targets '(html txt md))
  (define default-template-prefix "template"))

;; Load YAML data once with error handling
(define yaml-data 
  (if (file-exists? "data.yaml")
      (call-with-input-file "data.yaml" read-yaml)
      (hash))) ; empty hash if file doesn't exist

;; Helper function to get YAML values (handles both string and symbol keys)
(define (yaml-get key [default #f])
  (let ([str-key (if (symbol? key) (symbol->string key) key)]
        [sym-key (if (string? key) (string->symbol key) key)])
    (or (hash-ref yaml-data str-key #f)
        (hash-ref yaml-data sym-key #f)
        default)))

;; Helper for nested values - handles string/symbol keys
(define (yaml-get-nested . keys)
  (foldl (lambda (key acc) 
           (if (hash? acc)
               (let ([str-key (if (symbol? key) (symbol->string key) key)]
                     [sym-key (if (string? key) (string->symbol key) key)])
                 (or (hash-ref acc str-key #f)
                     (hash-ref acc sym-key #f)
                     #f))
               #f))
         yaml-data 
         keys))

;; Helper to format tag list
(define (format-tags)
  (let ([tags (yaml-get 'tags)])
    (if (and tags (list? tags))
        (string-join (map ~a tags) ", ")
        "No tags")))

;; Make functions available to Pollen files
(provide yaml-data yaml-get yaml-get-nested format-tags)
