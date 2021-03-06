#!/usr/bin/env newlisp

(module "getopts.lsp")

(load "include/clj.lsp")
(load "include/const.lsp")
(load "include/script.lsp")
(load "src/argparse.lsp")
(load "src/os.lsp")

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Constants
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(setq short-desc "An nmcli wrapper")
(setq version-string
  (format "%s - version %s (%s)" short-desc version release-year))

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Supporting functions
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(define (display-access-points)
  (! "nmcli device wifi list"))

(define (join-access-point cmd-args script)
  (if (= cmd-args '())
     (display-missing-subarg "join" script))
  (let ((ssid (first cmd-args))
        (cmd-args (rest cmd-args)))
    (println (format "Connecting to SSID %s ..." ssid))
    (if (= cmd-args '())
      (! (format "nmcli device wifi connect \"%s\"" ssid))
      (! (format "nmcli device wifi connect \"%s\" password %s"
                 ssid
                 (first cmd-args))))))

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Set up and parse options
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(define (usage script)
  (letn ((base-template "%s %-20s\t%s")
         (short-opt-template (append "\t -" base-template))
         (long-opt-template (append "\t--" base-template))
         (cmd-template (append "\t  " base-template)))
    (println)
    (println version-string)
    (println)
    (println
      (format "Usage: %s [options|command] [command options]" script))
    (println)
    (println "Options:")
    (dolist
      (o getopts:short)
      (println (format short-opt-template (o 0) "" (o 1 2))))
    (dolist
      (o getopts:long)
      (println (format long-opt-template (o 0) "" (o 1 2))))
    (println)
    (println "Commands:")
    (println
      (format cmd-template
              "scan"
              ""
              "Display a list of nearby access points"))
    (println
      (format cmd-template
              "join"
              "<SSID> <password>"
              "Join the access point with given password"))
    (exit)))

(shortopt "v" (display-script-info (argparse:get-script)) nil "Print version string")
(shortopt "h" (usage (argparse:get-script)) nil "Print this help message")
(longopt "help" (usage (argparse:get-script)) nil "Print this help message")

(new Tree 'parsed)
(parsed (argparse))

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Entry point
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(define (main script opts)
  (println)
  (os:platform-check '("Linux"))
  (cond
    ((empty? opts)
      (println)
      (println "ERROR: either an option or a command must be provided")
      (usage script)))
  (let ((cmd (first opts))
        (cmd-args (rest opts)))
    (case cmd
      ("scan" (display-access-points))
      ("join" (join-access-point cmd-args script))
      (true (display-unknown-cmd cmd script))))
  (exit))

;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; Run the program
;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(main (parsed "script")
      (parsed "opts"))
