;;; -*- Mode: Lisp; Syntax: Common-Lisp; -*-

;;;; study-paip.asd

(asdf:defsystem #:study-paip
    :name "study-paip"
    :version "1.0"
    :description "Source code from Peter Norvig book 'Paradigms of Artificial Intelligence Programming'"
    :author "Peter Norvig <peter@norvig.com>"
    :maintainer "Zlatozar Zhelyazkov <zlatozar@gmail.com>"

    :serial t
    :components ((:file "package")
                 (:file "tools/introspection")

                 ;; Helper functions and examples runner
                 (:file "auxfns" :depends-on ("package"))
                 (:file "tutor" :depends-on ("auxfns"))

                 ;; Book chapters
                 (:file "ch01/intro" :depends-on ("auxfns"))
                 (:file "ch01/examples" :depends-on ("tutor" "ch01/intro"))

                 (:file "ch02/simple")
                 (:file "ch02/examples" :depends-on ("tutor" "ch02/simple"))

                 (:file "ch03/overview")
                 (:file "ch03/examples" :depends-on ("tutor" "ch03/overview"))
                 ))
