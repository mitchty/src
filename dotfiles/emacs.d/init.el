;-*-mode: emacs-lisp; coding: utf-8;-*-

; General init.el file
; Simplify os detection a skosh
(defvar mswindows-p (string-match "windows" (symbol-name system-type))
  "Am I running under windows?")
(defvar osx-p (string-match "darwin" (symbol-name system-type))
  "Am I running under osx?")

; Yes, I miss perl chomp, sue me.
(defun chomp (str)
  "Chomp leading and trailing whitespace from STR."
  (let ((s (if (symbolp str) (symbol-name str) str)))
  (replace-regexp-in-string "\\(^[[:space:]\n]*\\|[[:space:]\n]*$\\)" "" s)))

; Base directory
(defvar load-base "~/.emacs.d"
  "Where the emacs directory is kept")

; Bootstrap load path
(add-to-list 'load-path load-base)

; Get rid of all of the stupid "look here's emacs" kthxbai
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
(setq inhibit-startup-echo-area-message t)

; Temp file dir (unixes)
(setq temporary-file-directory "/tmp")

;; OS SPECIFIC OVERRIDES OF most(ly) the above for os specific crap
(if osx-p (load "osx-settings"))
;(if mswindows-p (load "windows-settings")) TODO redo windows stuff
;; FIN

; Set the default temp file dir for the current user based off username
(defvar user-temporary-file-directory
  (format "%s/%s" temporary-file-directory user-login-name))

; mkdir if needed
(unless (file-accessible-directory-p user-temporary-file-directory)
  (make-directory user-temporary-file-directory t))

; What to do with backup crap/autosave files
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)
        (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))

; Change defaults to sane(r) values
(load "fix-defaults")

; What to do when we have a gui emacs not console
(cond (window-system
  ; Don't setup x windows paste behavior under osx
  (unless osx-p
    (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
    (setq scroll-bar-mode-explicit t)
    (setq x-select-enable-clipboard t))

  ; Mouse mode is ok to use
  (mouse-wheel-mode t)
  (mwheel-install)

  ; Nuke the stupid toolbar, put the scroll bar on the right (sic) side
  (tool-bar-mode -1)
  (set-scroll-bar-mode 'right)
  ))

; use desktop mode all the time
(desktop-save-mode 1)
(setq desktop-path '("~/"))
(setq desktop-dirname "~/")
(setq desktop-base-file-name ".emacs.desktop")

; mouse mode in tty is useful
(require 'mouse)
(xterm-mouse-mode t)
(defun track-mouse (e))
(setq mouse-sel-mode t)

; Setup package manager(s) n shit
(load "setup-el-get")
(load "setup-elpa")
(load "setup-package-post-install")

; Default file template stuff
(load "file-templates")

; use the emacs server daemon
(require 'server)
(unless (server-running-p)
  (server-start))
