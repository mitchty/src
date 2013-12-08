;;-*-mode: emacs-lisp; coding: utf-8;-*-

(add-to-list 'auto-mode-alist '("\\.[chm]\\'" . c-mode))

(add-hook 'c-mode-common-hook
          '(lambda ()
             (global-set-key "\C-x\C-m" 'compile)
             (add-to-list 'flycheck-clang-include-path ".")
             ;; buffer local save hook
             (when osx-p
               ;; Gating this to osx for the moment.
               ;; Setup flycheck/clang so it can find other header files.
               ;; not very pretty...
               (setq flycheck-clang-include-path
                     (delete ""
                             (split-string
                              (concat " "
                                      (shell-command-to-string
                                       "pkg-config --cflags glib-2.0 gsl")
                                      ) " -I")))
							 (add-hook 'before-save-hook 'clang-format-buffer nil t))
             (auto-complete-mode)
             (whitespace-mode)
             (hl-line-mode)
             (visual-line-mode)
             (smartparens-mode)
             (flycheck-mode)
             (linum-mode)
             (c-toggle-auto-state 1)
             (setq-default c-basic-offset 2
                           tab-width 2
                           indent-tabs-mode nil
                           c-electric-flag t
                           indent-level 2
                           c-default-style "bsd"
                           backward-delete-function nil)
             ))
