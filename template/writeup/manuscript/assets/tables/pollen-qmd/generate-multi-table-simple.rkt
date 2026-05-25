#lang racket/base

(require racket/file
         racket/path
         racket/cmdline
         racket/string
         racket/format
         racket/list
         json
         yaml)

;; Default values
(define table-id #f)
(define output-format 'typst)
(define output-file #f)
(define table-style #f)
(define list-tables? #f)
(define batch-generate? #f)

;; Base directories
(define tables-dir "tables")
(define shared-dir (build-path tables-dir "shared"))

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

;; Command line argument parsing - after function definitions
(define args
  (command-line
   #:program "generate-multi-table-simple"
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

;; Main execution logic based on flags
(cond
  ;; List available tables
  [list-tables?
   (printf "Available tables:\\n")
   (for-each (lambda (table)
               (let ([config (load-table-config table)])
                 (printf "  ~a: ~a\\n" table (hash-ref config "title"))))
             (get-available-tables))]
  
  ;; Process single table
  [table-id
   (if (member table-id (get-available-tables))
       (let* ([config (load-table-config table-id)]
              [data-config (hash-ref config "data")]
              [data-path (build-path tables-dir table-id "data" 
                                     (hash-ref data-config "source_file"))]
              [columns (hash-ref data-config "columns")]
              [default-style (hash-ref (hash-ref config "styles") "default")]
              [actual-style (or table-style default-style)]
              [prefix (hash-ref (hash-ref config "output") "filename_prefix")]
              [actual-output (or output-file 
                                (format "~a-~a-~a.qmd" prefix output-format actual-style))])
         
         ;; Load and process data
         (define table-data
           (let ([data-format (hash-ref data-config "format")])
             (cond
               [(string=? data-format "json")
                (let ([json-data (call-with-input-file data-path read-json)]
                      [col-names (map (lambda (col) (hash-ref col "name")) columns)])
                  (map (lambda (item)
                         (map (lambda (name)
                                (cons name (hash-ref item name "")))
                              col-names))
                       json-data))]
               [(string=? data-format "csv")
                (let ([lines (file->lines data-path)]
                      [col-names (map (lambda (col) (hash-ref col "name")) columns)])
                  (map (lambda (line)
                         (let ([parts (string-split line ",")])
                           (map (lambda (name part) 
                                  (cons name (string-trim part))) 
                                col-names parts)))
                       (rest lines)))] ; Skip header
               [(or (string=? data-format "yaml") (string=? data-format "yml"))
                (let ([yaml-data (call-with-input-file data-path read-yaml)]
                      [col-names (map (lambda (col) (hash-ref col "name")) columns)])
                  (map (lambda (item)
                         (map (lambda (name)
                                (cons name (hash-ref item name "")))
                              col-names))
                       yaml-data))]
               [else (error "Unsupported data format")])))
         
         ;; Generate content based on format
         (define content
           (let* ([templates-config (hash-ref config "templates")]
                  [content-config (hash-ref templates-config "content")]
                  [heading-template (hash-ref content-config "heading")]
                  [academic (hash-ref config "academic")]
                  [title (hash-ref config "title")]
                  [yaml-header (format "---
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

" title)]
                  [content-template (load-template table-id "content" heading-template)])
             
             (cond
               [(eq? output-format 'typst)
                (let* ([typst-config (hash-ref templates-config "typst")]
                       [custom-imports (let ([val (hash-ref typst-config "custom_imports" #f)])
                                         (if (eq? val 'null) #f val))]
                       [import-template (cond
                                          [custom-imports custom-imports]
                                          [(string=? actual-style "bordered") "table-imports-bordered.typ"]
                                          [else "table-imports.typ"])]
                       [table-function (cond
                                         [(string=? actual-style "bordered") "#bordered-table"]
                                         [(string=? table-id "table-2") "#performance-table"]
                                         [else "#three-line-table"])]
                       [header-row (string-join 
                                    (map (lambda (col) 
                                           (format "*~a*" (hash-ref col "display_name"))) 
                                         columns) 
                                    " | ")]
                       [separator-row (string-join 
                                       (make-list (length columns) "---") 
                                       "|")]
                       [table-header (format "  | ~a |\\n  |~a|\\n" header-row separator-row)]
                       [table-rows (apply string-append)
                                          (map (lambda (row)
                                                 (let ([row-values (map (lambda (col)
                                                                          (let ([col-name (hash-ref col "name")])
                                                                            (~a (cdr (assoc col-name row)))))
                                                                        columns)])
                                                   (format "  | ~a |\\n" (string-join row-values " | ")))
                                               table-data))]
                       [table-content (string-append table-header table-rows)])
                  (string-append
                    yaml-header
                    "```{=typst}\\n"
                    (string-trim (load-template table-id "typst" "page-setup.typ")) "\\n"
                    "```\\n\\n"
                    (string-trim content-template) "\\n\\n"
                    "```{=typst}\\n\\n"
                    (string-trim (load-template table-id "typst" import-template)) "\\n\\n"
                    "```\\n\\n"
                    "```{=typst}\\n"
                    table-function "[\\n"
                    table-content
                    "]\\n"
                    "```\\n"))]
               
               [(eq? output-format 'docx)
                (let* ([header-row (string-join 
                                    (map (lambda (col) 
                                           (format "*~a*" (hash-ref col "display_name"))) 
                                         columns) 
                                    " | ")]
                       [separator-row (string-join 
                                       (make-list (length columns) "---") 
                                       "|")]
                       [table-header (format "| ~a |\\n|~a|\\n" header-row separator-row)]
                       [table-rows (apply string-append
                                          (map (lambda (row)
                                                 (let ([row-values (map (lambda (col)
                                                                          (let ([col-name (hash-ref col "name")])
                                                                            (~a (cdr (assoc col-name row)))))
                                                                        columns)])
                                                   (format "| ~a |\\n" (string-join row-values " | ")))
                                               table-data)))
                       [table-content (string-append table-header table-rows)])
                  (string-append
                    yaml-header
                    (string-trim content-template) "\\n\\n"
                    table-content))]
               
               [else (error "Unsupported output format")])))
         
         ;; Write output file
         (display-to-file content actual-output #:exists 'replace)
         (printf "Generated ~a for table ~a (format: ~a, style: ~a)\\n" 
                 actual-output table-id output-format actual-style))
       
       (error (format "Table not found: ~a\\nAvailable tables: ~a" 
                      table-id (get-available-tables))))]
  
  ;; Show usage if no valid command
  [else
   (printf "Usage: racket generate-multi-table-simple.rkt [options]\\n")
   (printf "Options:\\n")
   (printf "  -t, --table TABLE_ID    Generate specific table\\n")
   (printf "  -f, --format FORMAT     Output format (typst or docx)\\n")
   (printf "  -s, --style STYLE       Table style (three-line or bordered)\\n")
   (printf "  -o, --output FILE       Output filename\\n")
   (printf "  -l, --list              List available tables\\n")])