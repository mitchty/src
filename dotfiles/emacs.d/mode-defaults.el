;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; Define a common/default(ish) set of mode settings.
;; I mostly use the same settings everywhere so simplify.
;; Autopair mode would be in here if the lisp modes didn't have
;; better
(setq mode-common-defaults '(
                            (auto-complete-mode)
                            (whitespace-mode)
                            (hl-line-mode)
                            (visual-line-mode)
                            (setq indent-tabs-mode nil)
                            (setq tab-width 2)
                            ))
