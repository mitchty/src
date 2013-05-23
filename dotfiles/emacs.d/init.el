;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; In case I screw up something later.
(setq debug-on-error t)

;; General init.el file
;; Simplify os detection a skosh
(defvar mswindows-p (string-match "windows" (symbol-name system-type))
  "Am I running under windows?")
(defvar osx-p (string-match "darwin" (symbol-name system-type))
  "Am I running under osx?")

;; Yes, I miss perl chomp, sue me.
(defun chomp (str)
  "Chomp leading and trailing whitespace from STR."
  (let ((s (if (symbolp str) (symbol-name str) str)))
  (replace-regexp-in-string "\\(^[[:space:]\n]*\\|[[:space:]\n]*$\\)" "" s)))

;; Base directory
(defvar load-base "~/.emacs.d" "Where the emacs directory is kept")

;; Bootstrap load path
(add-to-list 'load-path load-base)

;; Temp file dir (unixes)
(setq temporary-file-directory "/tmp")

;; Set the default temp file dir for the current user based off username
(defvar user-temporary-file-directory
  (format "%s/%s" temporary-file-directory user-login-name))

;; mkdir if needed
(unless (file-accessible-directory-p user-temporary-file-directory)
  (make-directory user-temporary-file-directory t))

;; Default file template stuff
(load "file-templates")

;; Load up settings of things, in no particular order or anything.
(mapcar 'load-file (directory-files "~/.emacs.d/settings/" t ".*.el$"))

;; Setup package manager(s) n shit
(load "setup-el-get")

;; Setup packages el-get installs.
(load "mode-defaults")
(load "setup-package-post-install")

;; Fine, emacsclient -c and emacs --daemon don't mix well
(load "server")
(unless (server-running-p) (server-start))
