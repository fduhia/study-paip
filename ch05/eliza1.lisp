;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CH5-FIRST; Base: 10 -*-

;;; Code from Paradigms of Artificial Intelligence Programming
;;; Copyright (c) 1991 Peter Norvig

;;;; File eliza1.lisp: Basic version of the Eliza program.

(in-package #:ch5-first)

;;; New version of `pat-base::pat-match' with segment variables denoted with (?* variable)

(defun pat-match (pattern input &optional (bindings no-bindings))
  "Match PATTERN against INPUT in the context of the BINDINGS"
  (cond ((eq bindings fail) fail)
        ((variable-p pattern)
         (match-variable pattern input bindings))
        ((eql pattern input) bindings)
        ((segment-pattern-p pattern)                ; ***
         (segment-match pattern input bindings))    ; ***
        ((and (consp pattern) (consp input))
         (pat-match (rest pattern) (rest input)
                    (pat-match (first pattern) (first input)
                               bindings)))
        (t fail)))

(defun segment-pattern-p (pattern)
  "Is this a segment matching PATTERN: ((?* var) . pat)"
  (and (consp pattern)
       (starts-with (first pattern) '?*)))

;;; ____________________________________________________________________________


;; In writing `segment-match', the important question is how much of the input the
;; segment variable should match. One answer is to look at the next element of the
;; pattern (the one after the segment variable) and see at what position it occurs in the
;; input.

(defun segment-match (pattern input bindings &optional (start 0))
  "Match the segment PATTERN ((?* var) . pat) against INPUT."
  (let ((var (second (first pattern)))
        (pat (rest pattern)))
    (if (null pat)
        (match-variable var input bindings)
        ;; We assume that pat starts with a constant
        ;; In other words, a pattern can't have 2 consecutive vars
        (let ((pos (position (first pat) input
                             :start start :test #'equal)))
          (if (null pos)
              fail
              ;; Pattern occurs but first we have to see if the rest of the
              ;; pattern matches the rest of the input
              (let ((b2 (pat-match pat (subseq input pos) bindings)))
                ;; If this match failed, try another longer one
                ;; If it worked, check that the variables match
                (if (eq b2 fail)
                    (segment-match pattern input bindings (+ pos 1))
                    (match-variable var (subseq input 0 pos) b2))))))))

;; Not works for following example:
;;
;; (pat-match  '((?* ?x) a b (?* ?x))  '(1 2 a b a b 1 2 a b))
;; NIL

;; This fails because ?x is matched against the sub-sequence (1 2), and then the remaining
;; pattern successfully matches the remaining input, but the final call to
;; `match-variable' fails, because ?x has two different values. The fix is to call
;; `match-variable' before testing whether the b2 fails, so that we will be sure to try
;; `segment-match' again with a longer match no matter what the cause of the failure.

(defun segment-match (pattern input bindings &optional (start 0))
  "Match the segment PATTERN ((?* var) . pat) against INPUT."
  (let ((var (second (first pattern)))
        (pat (rest pattern)))
    (if (null pat)
        (match-variable var input bindings)
        ;; We assume that pat starts with a constant
        ;; In other words, a pattern can't have 2 consecutive vars
        (let ((pos (position (first pat) input
                             :start start :test #'equal)))
          (if (null pos)
              fail
              (let ((b2 (pat-match
                         pat (subseq input pos)
                         (match-variable var (subseq input 0 pos)     ;; ***
                                         bindings))))
                ;; If this match failed, try another longer one
                (if (eq b2 fail)
                    (segment-match pattern input bindings (+ pos 1))
                    b2)))))))

;;; ____________________________________________________________________________
;;;                                                    Simple rules for testing

(defparameter *eliza-rules*
  '((((?* ?x) hello (?* ?y))
     (How do you do.  Please state your problem.))
    (((?* ?x) I want (?* ?y))
     (What would it mean if you got ?y)
     (Why do you want ?y) (Suppose you got ?y soon))
    (((?* ?x) if (?* ?y))
     (Do you really think its likely that ?y) (Do you wish that ?y)
     (What do you think about ?y) (Really-- if ?y))
    (((?* ?x) no (?* ?y))
     (Why not?) (You are being a bit negative)
     (Are you saying "NO" just to be negative?))
    (((?* ?x) I was (?* ?y))
     (Were you really?) (Perhaps I already knew you were ?y)
     (Why do you tell me you were ?y now?))
    (((?* ?x) I feel (?* ?y))
     (Do you often feel ?y ?))
    (((?* ?x) I felt (?* ?y))
     (What other feelings do you have?))))

;;; ____________________________________________________________________________
;;;                                                           Run first version

;;; First is the pattern second are the responses

(defun rule-pattern (rule) (first rule))
(defun rule-responses (rule) (rest rule))

(defun eliza ()
  "Respond to user input using pattern matching rules."
  (loop
     (print 'eliza>)
     (write (flatten (use-eliza-rules (read))) :pretty t)))

;; Do you remember how sublis works? See p. 76 if not.
;; How to choose when there is many possibilities to answer? Use `paip-aux:random-elt'

(defun use-eliza-rules (input)
  "Find some rule with which to transform the INPUT."
  (some #'(lambda (rule)
            (let ((result (pat-match (rule-pattern rule) input)))
              (if (not (eq result fail))
                  (sublis (switch-viewpoint result)
                          (random-elt (rule-responses rule))))))
        *eliza-rules*))

(defun switch-viewpoint (words)
  "Change I to you and vice versa, and so on."
  (sublis '((I . you) (you . I) (me . you) (am . are))
          words))

;;; ____________________________________________________________________________
;;;                                                    Example of ELIZA session

;;; NOTE: There is no punctuation especially comma and sexp are not quoted.

;;; ch5-first> (eliza)
;;; ELIZA> (hello there)
;;; (HOW DO YOU DO. PLEASE STATE YOUR PROBLEM.)
;;; ELIZA> (i want to test this program)
;;; (WHAT WOULD IT MEAN IF YOU GOT TO TEST THIS PROGRAM)
;;; ELIZA> (i could see if it works)
;;; (DO YOU REALLY THINK ITS LIKELY THAT IT WORKS)
;;; ELIZA> (no not really)
;;; (ARE YOU SAYING "NO" JUST TO BE NEGATIVE?)
;;; ELIZA> (no)
;;; (ARE YOU SAYING "NO" JUST TO BE NEGATIVE?)
;;; ELIZA> (forget it-- i was wondering how general the program is)
;;; (WHY DO YOU TELL ME YOU WERE WONDERING HOW GENERAL THE PROGRAM IS NOW?)
;;; ELIZA> (i felt like it)
;;; (WHAT OTHER FEELINGS DO YOU HAVE?)
;;; ELIZA> (i feel this is enough)
;;; (DO YOU OFTEN FEEL THIS IS ENOUGH ?)
;;; ELIZA> [Abort. Use C-c C-c in SLIME then pick up [Abort]]
