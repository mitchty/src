;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; mouse mode in tty is useful
(require 'mouse)
(xterm-mouse-mode t)
(unless window-system
  (defun track-mouse (e)))
(setq mouse-sel-mode t)
