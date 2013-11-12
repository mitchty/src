;;-*-mode: emacs-lisp; coding: utf-8;-*-

(add-to-list 'auto-mode-alist '("\\.c$\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.[chm]\\'" . c-mode))
;;(add-to-list 'auto-mode-alist '("\\.cxx\\'" . c-mode))

(add-hook 'c-mode-common-hook
          '(lambda ()
             (auto-complete-mode)
             (whitespace-mode)
             (hl-line-mode)
             (visual-line-mode)
             (setq indent-tabs-mode nil)
             (setq tab-width 2)
             (smartparens-mode)
             (flycheck-mode)
             (c-toggle-auto-state 1)
             (setq-default c-electric-flag t)
             (setq-default indent-tabs-mode t)
             (setq-default tab-width 4)
             (setq-default c-basic-offset 4)
             (setq-default c-default-style "bsd")
             ))
