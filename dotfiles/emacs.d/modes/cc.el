;;-*-mode: emacs-lisp; coding: utf-8;-*-

(add-to-list 'auto-mode-alist '("\\.[chm]\\'" . c-mode))

(add-hook 'c-mode-common-hook
          '(lambda ()
             (global-set-key "\C-x\C-m" 'compile)
             ;; buffer local save hook
             (add-hook 'before-save-hook 'clang-format-buffer nil t)
             (auto-complete-mode)
             (whitespace-mode)
             (hl-line-mode)
             (visual-line-mode)
             (smartparens-mode)
             (flycheck-mode)
             (c-toggle-auto-state 1)
             (setq-default c-basic-offset 2
                           tab-width 2
                           indent-tabs-mode nil
                           c-electric-flag t
                           indent-level 2
                           c-default-style "bsd"
                           backward-delete-function nil)
             ))
