;;-*-mode: emacs-lisp; coding: utf-8;-*-
(auto-complete-mode)
(whitespace-mode)
(hl-line-mode)
(smartparens-mode)
(visual-line-mode)
(setq indent-tabs-mode nil)
(setq tab-width 2)
;; Use diff-hl-mode under a window system, and since there is
;; no fringe in console mode use diff-hl-margin-mode then.
(when window-system (diff-hl-mode)
      (diff-hl-margin-mode))
