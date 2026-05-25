◊(apply string-append (map (lambda (x)
                             (cond
                               [(string? x) x]
                               [(symbol? x) ""]
                               [else ""]))
                           (cdr doc)))
