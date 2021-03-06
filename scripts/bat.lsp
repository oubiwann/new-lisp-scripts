#!/usr/bin/env newlisp

(module "getopts.lsp")

(load "include/const.lsp")
(load "include/clj.lsp")
(load "include/script.lsp")
(load "src/argparse.lsp")
(load "src/os.lsp")

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Constants
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(setq heading "Battery status")
(setq short-desc (format "%s tool" heading))
(setq version-string
  (format "%s - version %s (%s)" short-desc version release-year))

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Supporting functions
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(define (get-bat-device-path)
  (->> (exec "upower -e")
       (map (lambda (x) (regex ".*BAT.*" x)))
       (clean nil?)
       (first)
       (first)))

(define (get-bat-info bat-path)
  (exec (append "upower -i " bat-path)))

(define (bat-info? line)
  (or (find "state" line)
      (find "to full" line)
      (find "percentage" line)))

(define (get-status)
  (->> (get-bat-device-path)
       (get-bat-info)
       (filter bat-info?)))

(define (usage)
  (println)
  (println version-string)
  (println)
  (argparse:default-usage))

(define (display lines)
  (map println lines))

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Set up and parse options
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(shortopt "v" (display-script-info (argparse:get-script)) nil "Print version string")
(shortopt "h" (usage) nil "Print this help message")
(longopt "help" (usage) nil "Print this help message")

(new Tree 'parsed)
(parsed (argparse))

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Entry point
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(define (main)
  (println)
  (os:platform-check '("Linux"))
  (println (append heading ":"))
  (display (get-status))
  (exit))

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Run the program
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(main)
