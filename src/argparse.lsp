;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; argparse Module
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;;
;;; A supplemental module for getopts that handles args, script names, and
;;; options when running newlisp scripts or newlisp linked executables.
;;;
;;; (c) 2016, Duncan McGreggor

(context 'argparse)

(module "getopts.lsp")

(define (get-script-name argv)
  (let (arg1 (first argv))
    (case (length argv)
      (0 "")
      (1 (if (= arg1 "newlisp")
            ""
            arg1))
      (true (if (= arg1 "newlisp")
              (nth 1 argv)
              arg1)))))

(define (get-script)
  (get-script-name (main-args)))

(define (-get-opts argv-tail)
  (case (length argv-tail)
    (0 '())
    (true argv-tail)))

(define (get-opts argv)
  (if (starts-with (first argv) "newlisp")
     (-get-opts (2 argv))
     (-get-opts (1 argv))))

(define (argparse:argparse)
  (letn ((argv (main-args))
         (script (get-script-name argv))
         (opts (get-opts argv)))
    (getopts opts)
    (list
      (list "args" argv)
      (list "script" script)
      (list "opts" opts))))

(define (default-usage)
  (getopts:usage))

(context MAIN)
