#lang racket/base

(require racket/file
         racket/path
         racket/cmdline
         racket/string
         racket/format
         racket/list
         json
         yaml)

;; Global configuration
(define table-id #f)
(define output-format 'typst)
(define output-file #f)
(define table-style #f)
(define list-tables? #f)
(define batch-generate? #f)

;; Base directories
(define tables-dir "tables")
(define shared-dir (build-path tables-dir "shared"))

;; Command line argument parsing
(define args
  (command-line
   #:program "generate-multi-table"
   #:once-each
   [("-t" "--table") table-name
    "Table ID to generate (e.g., table-1)"
    (set! table-id table-name)]
   [("-f" "--format") format-str
    "Output format (typst or docx)"
    (set! output-format (string->symbol format-str))]
   [("-o" "--output") output-path
    "Output QMD file"
    (set! output-file output-path)]
   [("-s" "--style") style-str
    "Table style (three-line or bordered)"
    (set! table-style style-str)]
   [("-l" "--list") 
    "List available tables"
    (set! list-tables? #t)]
   [("-b" "--batch")
    "Generate all available tables"
    (set! batch-generate? #t)]
   #:args ()
   '()))

;; Utility functions
(define (get-available-tables)
  "Get list of available table directories"
  (if (directory-exists? tables-dir)
      (map path->string
           (filter (lambda (dir)
                     (and (directory-exists? (build-path tables-dir dir))
                          (file-exists? (build-path tables-dir dir "metadata" "config.yaml"))))
                   (directory-list tables-dir)))
      '()))

(define (load-table-config table-id)
  "Load table configuration from metadata/config.yaml"
  (let ([config-path (build-path tables-dir table-id "metadata" "config.yaml")])
    (if (file-exists? config-path)
        (call-with-input-file config-path read-yaml)
        (error (format "Configuration file not found: ~a" config-path)))))

(define (get-table-data-path table-id config)
  "Get the path to the table's data file"
  (let ([data-config (hash-ref config "data")]
        [source-file (hash-ref (hash-ref config "data") "source_file")])
    (build-path tables-dir table-id "data" source-file)))

(define (get-template-path table-id template-type filename)
  "Get path to template file, checking table-specific first, then shared"
  (let ([table-specific (build-path tables-dir table-id "templates" template-type filename)]
        [shared-path (build-path shared-dir (format "~a-templates" template-type) filename)])
    (cond
      [(file-exists? table-specific) table-specific]
      [(file-exists? shared-path) shared-path]
      [else (error (format "Template not found: ~a" filename))])))

(define (load-template table-id template-type filename)
  "Load template content from file"
  (let ([template-path (get-template-path table-id template-type filename)])
    (file->string template-path)))

;; Data loading functions (enhanced from original)
(define (load-csv-data filename columns)
  "Load CSV data with column mapping"
  (let ([lines (file->lines filename)])
    (map (lambda (line)
           (let ([parts (string-split line ",")]
                 [col-names (map (lambda (col) (hash-ref col "name")) columns)])
             (map (lambda (name part) 
                    (cons name (string-trim part))) 
                  col-names parts)))
         (rest lines)))) ; Skip header

(define (load-json-data filename columns)
  "Load JSON data with column mapping"
  (let ([json-data (call-with-input-file filename read-json)]
        [col-names (map (lambda (col) (hash-ref col "name")) columns)])
    (if (list? json-data)
        (map (lambda (item)
               (if (hash? item)
                   (map (lambda (name)
                          (cons name (hash-ref item name "")))
                        col-names)
                   '()))
             json-data)
        '())))

(define (load-yaml-data filename columns)
  "Load YAML data with column mapping"
  (let ([yaml-data (call-with-input-file filename read-yaml)]
        [col-names (map (lambda (col) (hash-ref col "name")) columns)])
    (if (list? yaml-data)
        (map (lambda (item)
               (if (hash? item)
                   (map (lambda (name)
                          (cons name (hash-ref item name "")))
                        col-names)
                   '()))
             yaml-data)
        '())))

(define (load-table-data table-id config)
  "Load table data based on configuration"
  (let* ([data-config (hash-ref config "data")]
         [data-path (get-table-data-path table-id config)]
         [data-format (hash-ref data-config "format")]
         [columns (hash-ref data-config "columns")])
    (cond
      [(string=? data-format "csv") (load-csv-data data-path columns)]
      [(string=? data-format "json") (load-json-data data-path columns)]
      [(or (string=? data-format "yaml") (string=? data-format "yml"))
       (load-yaml-data data-path columns)]
      [else (error (format "Unsupported data format: ~a" data-format))])))

;; Template system functions
(define (get-typst-import-template table-id config style)
  "Get Typst import template based on configuration and style"
  (let* ([templates-config (hash-ref config "templates")]
         [typst-config (hash-ref templates-config "typst")]
         [custom-imports (hash-ref typst-config "custom_imports" #f)])
    (cond
      [custom-imports custom-imports]
      [(string=? style "bordered") "table-imports-bordered.typ"]
      [else "table-imports.typ"])))

(define (get-typst-function-name table-id config style)
  "Get Typst table function name"
  (let* ([templates-config (hash-ref config "templates")]
         [typst-config (hash-ref templates-config "typst")]
         [custom-function (hash-ref typst-config "custom_functions" #f)])
    (cond
      [custom-function (format "#~a" custom-function)]
      [(string=? style "bordered") "#bordered-table"]
      [(string=? table-id "table-2") "#performance-table"]  ; Special case for performance table
      [else "#three-line-table"])))

(define (get-content-template table-id config)
  "Get content template filename"
  (let* ([templates-config (hash-ref config "templates")]
         [content-config (hash-ref templates-config "content")]
         [heading-template (hash-ref content-config "heading")])
    heading-template))

;; YAML front matter generation
(define (generate-yaml-header config)
  "Generate YAML front matter from table configuration"
  (let* ([academic (hash-ref config "academic")]
         [title (hash-ref config "title")]
         [label (hash-ref academic "label")]
         [caption (hash-ref academic "caption")])
    (format "---
title: \"~a\"
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

" title)))

;; Table rendering functions
(define (render-table-header columns output-fmt)
  "Render table header based on column configuration"
  (let ([header-row (string-join 
                     (map (lambda (col) 
                            (format "*~a*" (hash-ref col "display_name"))) 
                          columns) 
                     " | ")]
        [separator-row (string-join 
                        (make-list (length columns) "---") 
                        "|")])
    (cond
      [(eq? output-fmt 'typst)
       (format "  | ~a |\\n  |~a|\\n" header-row separator-row)]
      [(eq? output-fmt 'docx)
       (format "| ~a |\\n|~a|\\n" header-row separator-row)]
      [else (format "| ~a |\\n|~a|\\n" header-row separator-row)])))

(define (render-table-row row-data columns output-fmt)
  "Render a single table row"
  (let ([row-values (map (lambda (col)
                           (let ([col-name (hash-ref col "name")])
                             (cdr (assoc col-name row-data))))
                         columns)])
    (cond
      [(eq? output-fmt 'typst) 
       (format "  | ~a |\\n" (string-join row-values " | "))]
      [(eq? output-fmt 'docx) 
       (format "| ~a |\\n" (string-join row-values " | "))]
      [else (format "| ~a |\\n" (string-join row-values " | "))])))

(define (render-table-data table-data columns output-fmt)
  "Render complete table data"
  (apply string-append
    (cons (render-table-header columns output-fmt)
          (map (lambda (row) (render-table-row row columns output-fmt)) table-data))))

;; Content generators
(define (generate-typst-content table-id config table-data style)
  "Generate Typst QMD content"
  (let* ([columns (hash-ref (hash-ref config "data") "columns")]
         [content-template (get-content-template table-id config)]
         [import-template (get-typst-import-template table-id config style)]
         [table-function (get-typst-function-name table-id config style)])
    (string-append
      (generate-yaml-header config)
      "```{=typst}\\n"
      (string-trim (load-template table-id "typst" "page-setup.typ")) "\\n"
      "```\\n\\n"
      (string-trim (load-template table-id "content" content-template)) "\\n\\n"
      "```{=typst}\\n\\n"
      (string-trim (load-template table-id "typst" import-template)) "\\n\\n"
      "```\\n\\n"
      "```{=typst}\\n"
      table-function "[\\n"
      (render-table-data table-data columns 'typst)
      "]\\n"
      "```\\n")))

(define (generate-docx-content table-id config table-data)
  "Generate DOCX QMD content"
  (let* ([columns (hash-ref (hash-ref config "data") "columns")]
         [content-template (get-content-template table-id config)])
    (string-append
      (generate-yaml-header config)
      (string-trim (load-template table-id "content" content-template)) "\\n\\n"
      (render-table-data table-data columns 'docx))))

;; Main generation function
(define (generate-table table-id current-format style output-filename)
  "Generate a single table"
  (let* ([config (load-table-config table-id)]
         [table-data (load-table-data table-id config)]
         [default-style (hash-ref (hash-ref config "styles") "default")]
         [actual-style (or style default-style)]
         [prefix (hash-ref (hash-ref config "output") "filename_prefix")]
         [actual-output (or output-filename 
                            (format "~a-~a-~a.qmd" prefix current-format actual-style))])
    
    (define content
      (cond
        [(eq? current-format 'typst) (generate-typst-content table-id config table-data actual-style)]
        [(eq? current-format 'docx) (generate-docx-content table-id config table-data)]
        [else (error "Unsupported output format")]))
    
    (display-to-file content actual-output #:exists 'replace)
    (printf "Generated ~a for table ~a (format: ~a, style: ~a)\\n" 
            actual-output table-id current-format actual-style)
    actual-output))

;; Main execution logic
(cond
  [list-tables?
   (printf "Available tables:\\n")
   (for-each (lambda (table)
               (let ([config (load-table-config table)])
                 (printf "  ~a: ~a\\n" table (hash-ref config "title"))))
             (get-available-tables))]
  
  [batch-generate?
   (printf "Generating all tables...\\n")
   (for-each (lambda (table)
               (let ([config (load-table-config table)])
                 (printf "Processing ~a...\\n" table)
                 (generate-table table 'typst "three-line" #f)
                 (generate-table table 'docx #f #f)))
             (get-available-tables))
   (printf "Batch generation completed.\\n")]
  
  [table-id
   (if (member table-id (get-available-tables))
       (generate-table table-id output-format table-style output-file)
       (error (format "Table not found: ~a\\nAvailable tables: ~a" 
                      table-id (get-available-tables))))]
  
  [else
   (printf "Usage: racket generate-multi-table.rkt [options]\\n")
   (printf "Options:\\n")
   (printf "  -t, --table TABLE_ID    Generate specific table\\n")
   (printf "  -f, --format FORMAT     Output format (typst or docx)\\n")
   (printf "  -s, --style STYLE       Table style (three-line or bordered)\\n")
   (printf "  -o, --output FILE       Output filename\\n")
   (printf "  -l, --list              List available tables\\n")
   (printf "  -b, --batch             Generate all tables\\n")])