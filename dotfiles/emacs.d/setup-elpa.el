;-*-mode: emacs-lisp; coding: utf-8;-*-

; elpa setup
(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '(
    "melpa" . "http://melpa.milkbox.net/packages/") t)
  (add-to-list 'package-archives '(
    "gnu" . "http://elpa.gnu.org/packages/") t)
  (add-to-list 'package-archives '(
    "marmalade" . "http://marmalade-repo.org/packages/") t)
  (add-to-list 'package-archives '(
    "org" . "http://orgmode.org/elpa/") t)
  (unless package-archive-contents
    (package-refresh-contents))
  (mapc (lambda (package)
          (unless (package-installed-p package)
    (package-install package)))
    (list
'org
;'autopair
'tramp
'color-theme
'color-theme-solarized
    ))
  (package-initialize))
