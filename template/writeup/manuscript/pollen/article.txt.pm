#lang pollen

# ◊(yaml-get 'title "Untitled")

**By:** ◊(yaml-get 'author "Unknown Author")  
**Date:** ◊(yaml-get 'date "No date")  
**Tags:** ◊(format-tags)

---

## Introduction

This article demonstrates how to use YAML data within Pollen markdown files. 

◊(if (yaml-get-nested 'meta 'published)
     "✅ This article is published and ready to read!"
     "⚠️ This article is still in draft mode.")

## Content Section

You can mix regular markdown with Pollen functions that access your YAML data.

- **Author:** ◊(yaml-get 'author "Unknown")
- **Publication status:** ◊(if (yaml-get-nested 'meta 'published) "Published" "Draft")
- **Number of tags:** ◊(let ([tags (yaml-get 'tags '())])
                          (if (list? tags) (length tags) 0))

### Dynamic Content

◊(define article-tags (yaml-get 'tags '()))
◊(if (and article-tags (not (null? article-tags)))
     (apply string-append 
            (map (lambda (tag) 
                   (format "- This article covers **~a**\n" tag)) 
                 article-tags))
     "No tags available for this article.\n")

## Conclusion

◊(let ([desc (yaml-get-nested 'meta 'description)])
   (if desc 
       (format "The description from our YAML file says: \"~a\"" desc)
       "No description available."))

*End of article by ◊(yaml-get 'author "Unknown Author")*
