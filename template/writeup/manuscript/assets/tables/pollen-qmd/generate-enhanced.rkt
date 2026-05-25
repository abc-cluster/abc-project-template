#lang racket/base

(require racket/file
         racket/path
         racket/cmdline
         racket/string
         racket/format
         racket/list
         json)

(define output-format 'typst)
(define data-file #f) ; Will be auto-detected
(define output-file "table-1-generated.qmd")
(define table-style "three-line") ; or "bordered"

;; Template directories
(define typst-templates-dir "typst-templates")
(define content-templates-dir "content-templates")

;; Command line argument parsing
(define args
  (command-line
   #:program "generate-enhanced"
   #:once-each
   [("-f" "--format") format-str
    "Output format (typst or docx)"
    (set! output-format (string->symbol format-str))]
   [("-d" "--data") data-path
    "Data file (CSV, JSON, YAML)"
    (set! data-file data-path)]
   [("-o" "--output") output-path
    "Output QMD file"
    (set! output-file output-path)]
   [("-s" "--style") style-str
    "Table style (three-line or bordered)"
    (set! table-style style-str)]
   #:args ()
   '()))

;; Template loading functions
(define (load-typst-template filename)
  "Load Typst template from external file"
  (let ([file-path (build-path typst-templates-dir filename)])
    (if (file-exists? file-path)
        (file->string file-path)
        (error (format "Typst template not found: ~a" file-path)))))

(define (load-content-template filename)
  "Load content template from external file"
  (let ([file-path (build-path content-templates-dir filename)])
    (if (file-exists? file-path)
        (file->string file-path)
        (error (format "Content template not found: ~a" file-path)))))

(define (get-table-import-template style)
  "Get the appropriate table import template based on style"
  (cond
    [(string=? style "three-line") "table-imports.typ"]
    [(string=? style "bordered") "table-imports-bordered.typ"]
    [else "table-imports.typ"]))

(define (get-table-function-name style)
  "Get the appropriate table function name based on style"
  (cond
    [(string=? style "three-line") "#three-line-table"]
    [(string=? style "bordered") "#bordered-table"]
    [else "#three-line-table"]))

;; Data loading functions (same as before)
(define (load-csv-data filename)
  (let ([lines (file->lines filename)])
    (map (lambda (line)
           (let ([parts (string-split line ",")])
             (list (string-trim (first parts))
                   (string-trim (second parts)))))
         (rest lines)))) ; Skip header row

(define (load-json-data filename)
  (let ([json-data (call-with-input-file filename read-json)])
    (if (list? json-data)
        (map (lambda (item)
               (if (hash? item)
                   (list (hash-ref item "theme" "")
                         (hash-ref item "feature" ""))
                   (list "" "")))
             json-data)
        '())))

(define (load-yaml-data filename)
  (let ([lines (file->lines filename)])
    (filter-map (lambda (line)
                  (let ([trimmed (string-trim line)])
                    (if (and (not (string=? trimmed ""))
                             (not (string-prefix? trimmed "#"))
                             (string-contains? trimmed ":"))
                        (let ([parts (string-split trimmed ":")])
                          (list (string-trim (first parts))
                                (string-trim (second parts))))
                        #f)))
                lines)))

(define (load-table-data filename)
  (cond
    [(string-suffix? filename ".json") (load-json-data filename)]
    [(string-suffix? filename ".csv") (load-csv-data filename)]
    [(or (string-suffix? filename ".yaml")
         (string-suffix? filename ".yml")) (load-yaml-data filename)]
    [else (error "Unsupported file format")]))

;; YAML front matter
(define yaml-header
  "---
title: \"\"
author: \"\"

format:
    docx: default
    typst:
        mainfont: \"Ubuntu\"
        keep-typ: true
execute:
  echo: false
  warning: false

---

")

;; Table rendering functions
(define (render-table-row theme feature output-fmt)
  (cond
    [(eq? output-fmt 'typst) (format "  | ~a | ~a |\n" theme feature)]
    [(eq? output-fmt 'docx) (format "| ~a | ~a |\n" theme feature)]
    [else (format "| ~a | ~a |\n" theme feature)]))

(define (render-table-header output-fmt)
  (cond
    [(eq? output-fmt 'typst)
     "  | *Theme*         | *Feature*                   |\n  |-------------------|-------------------------------|\n"]
    [(eq? output-fmt 'docx)
     "| *Theme*         | *Feature*                   |\n|-------------------|-------------------------------|\n"]
    [else "| *Theme*         | *Feature*                   |\n|-------------------|-------------------------------|\n"]))

(define (render-table-data table-data output-fmt)
  (apply string-append
    (cons (render-table-header output-fmt)
          (map (lambda (row) (render-table-row (car row) (cadr row) output-fmt)) table-data))))

;; Enhanced content generators with style support
(define (generate-typst-content table-data style)
  (string-append
    yaml-header
    "```{=typst}\n"
    (string-trim (load-typst-template "page-setup.typ")) "\n"
    "```\n\n"
    (string-trim (load-content-template "table-1-heading.md")) "\n\n"
    "```{=typst}\n"
    "\\\n"
    "\\\n"
    "```\n\n"
    "```{=typst}\n\n"
    (string-trim (load-typst-template (get-table-import-template style))) "\n\n"
    "```\n\n"
    "```{=typst}\n"
    (get-table-function-name style) "[\n"
    (render-table-data table-data 'typst)
    "]\n"
    "```\n"))

(define (generate-docx-content table-data)
  (string-append
    yaml-header
    (string-trim (load-content-template "table-1-heading.md")) "\n\n"
    "\n"
    (render-table-data table-data 'docx)))

;; Data file auto-detection if not specified
(unless data-file
  (cond
    [(file-exists? "data.csv") (set! data-file "data.csv")]
    [(file-exists? "data.json") (set! data-file "data.json")]
    [(file-exists? "data.yaml") (set! data-file "data.yaml")]
    [(file-exists? "data.yml") (set! data-file "data.yml")]
    [else (error "No data file found. Expected: data.csv, data.json, or data.yaml")]))

;; Main execution
(define table-data (load-table-data data-file))
(define content
  (cond
    [(eq? output-format 'typst) (generate-typst-content table-data table-style)]
    [(eq? output-format 'docx) (generate-docx-content table-data)]
    [else (error "Unsupported output format")]))

(display-to-file content output-file #:exists 'replace)
(printf "Generated ~a for format: ~a with style: ~a (external templates!)\n" output-file output-format table-style)