(ns portal.portal)

;; for node and jvm
(require '[portal.api :as p])

(def p (p/open)) ; Open a new inspector

(def p (p/open {:launcher :vs-code}))  ; jvm / node only
(def p (p/open {:launcher :intellij})) ; jvm / node only

(add-tap #'p/submit) ; Add portal as a tap> target

(tap> :hello) ; Start tapping out values

(p/clear) ; Clear all values

(tap> :world) ; Tap out more values

(prn @p) ; bring selected value back into repl

(remove-tap #'p/submit) ; Remove portal from tap> targetset

(p/close) ; Close the inspector when done

(p/docs) ; View docs locally via Portal - jvm / node only
