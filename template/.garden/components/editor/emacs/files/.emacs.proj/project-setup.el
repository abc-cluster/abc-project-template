;;; project-setup.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Abhinav Sharma
;;
;; Author: Abhinav Sharma <abhinavsharma@hey.com>
;; Maintainer: Abhinav Sharma <abhinavsharma@hey.com>
;; Created: May 25, 2025
;; Modified: May 25, 2025
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/eklavya/project-setup
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:


(setq org-capture-templates
      '(("e" "Experiment" entry (file "~/org/experiments.org")
         "* Experiment: %^{Title}
:PROPERTIES:
:DATE: %U
:STATUS: planned
:END:
** Objective
%?
** Method
** Code
#+BEGIN_SRC python :results output
#+END_SRC
** Results
** Analysis
** Next Steps
")))


(provide 'project-setup)
;;; project-setup.el ends here
