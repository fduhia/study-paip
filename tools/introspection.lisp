;;; -*- Mode: Lisp; Syntax: Common-Lisp; -*-

;;;; File introspection.lisp: Miscellaneous functions that could be used to understand PAIP code.

(in-package #:inspect)

;;; ____________________________________________________________________________
;;;                                                             Examine symbols

(defvar *system-packages*
  '("SB-" "SWANK" "UIOP""QL-" "ASDF" "QUICKLISP" "BORDEAUX-" "HTML-TEMPLATE" "::")
  "Packages that are not helpful during PAIP study.")

(defun system-symbol-p (aprop-symbol)
  "Checks if `aprop-symbol' is exposed and if it is part of system
packages."
  (let ((system-list *system-packages*))
    (some 'numberp (mapcar #'(lambda (x) (search x (format nil "~S" aprop-symbol)))
                           system-list))))

(defun start-with-p (aprop-symbol)
  "Checks if `aprop-symbol' is a keyword."
  (eql (search ":" (format nil "~S" aprop-symbol)) 0))

(defun spec-constraint-p (aprop-symbol)
  "Predicate used to filter 'apropos-list."
  (or (system-symbol-p aprop-symbol)
      (start-with-p aprop-symbol)))

(defun ?a (&optional (sub-string ""))
  "Return a list of all symbols containing `sub-string' as a substring."
  (format t "~{~S,~% ~}" (sort
                          (remove-if #'spec-constraint-p (apropos-list sub-string))
                          #'string-lessp)))

(defun ?? (some-symbol)
  "Verbosely describe a symbol"
  (describe some-symbol))

;;; ____________________________________________________________________________
;;;                                                            Examine packages

(defun ?p~ (&optional (package (package-name *package*)))
  "Return a list of internal symbols in `package' name.
If `package' is not specified, internal symbols of current
package will be displayed."
  (let ((rslt nil))
    (do-symbols (s package)
      (when (eq (second
                 (multiple-value-list
                  (find-symbol (symbol-name s) package)))
                :internal)
        (push s rslt)))
    (format t "~{~S,~% ~}" (sort rslt #'string-lessp))))

(defun ?p+ (&optional (package (package-name *package*)))
  "Return a list of external symbols in `package' name.
If `package' is not specified, external symbols of current
package will be displayed."
  (let ((rslt nil))
    (do-external-symbols (s package)
      (push s rslt))
    (format t "~{~S,~% ~}" (sort rslt #'string-lessp))))

(defun ?p* ()
  "Return a list of all package names."
  (let ((reslist (mapcar #'package-name
                         (list-all-packages))))
    (format t "~{~S,~% ~}" (sort reslist #'string-lessp))))

(defun ?p% (&optional (package (package-name *package*)))
  "Return a non-portable description for `package' name, via DESCRIBE."
  (with-output-to-string (sstream)
    (describe (find-package package) sstream)))

;;; ____________________________________________________________________________
;;;                                                              Examine macros

(defmacro ?mac (expr)
  "Pretty-print the results of calling macroexpand-1 on `expr'."
  `(pprint (macroexpand-1 ',expr)))
