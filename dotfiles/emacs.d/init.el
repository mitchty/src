;;-*-mode: emacs-lisp; coding: utf-8;-*-
;; In case I screw up something later, debug stuff
(setq debug-on-error t)

;; Simplify os detection a skosh
(defvar mswindows-p (string-match "windows" (symbol-name system-type))
  "Am I running under windows?")
(defvar osx-p (string-match "darwin" (symbol-name system-type))
  "Am I running under osx?")

;; Yes, I miss perl chomp, sue me
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

;; mkdir for temporary-file-directory if needed
(unless (file-accessible-directory-p user-temporary-file-directory)
  (make-directory user-temporary-file-directory t))

;; Load up settings of things, in no particular order or anything
(mapcar 'load-file (directory-files "~/.emacs.d/settings/" t ".*.el$"))

;; Setup/install third party packages
(load "el-get")

;; Load up settings for things that el-get installed
(mapcar 'load-file (directory-files "~/.emacs.d/package-settings/" t ".*.el$"))

;; Cleanup startup buffers
(add-hook 'after-init-hook
          '(lambda () (delete-other-windows)))

;; Fine, emacsclient -c and emacs --daemon don't mix well
;; From now on I start emacs as a gui and have this startup the daemon
(load "server")
(unless (server-running-p) (server-start))
