;;-*-mode: emacs-lisp; coding: utf-8;-*-
(interactive)
(highlight-lines-matching-regexp ".\{81\}" 'hi-green-b)
(hi-lock-mode)
(hl-line-mode)
(auto-complete-mode)
(whitespace-mode)
(smartparens-mode)
(visual-line-mode)
(setq indent-tabs-mode nil)
(setq tab-width 2)
