(autoload 'makefile-mode "makefile-mode" "mode for makefile stuff" t)

(add-to-list 'auto-mode-alist '("\\.[Mm]akefile$" . makefile-mode))
(add-to-list 'auto-mode-alist '("\\.GNUMakefile$" . makefile-mode))

(add-hook 'makefile-mode-hook
          '(lambda ()
             (autopair-mode)
             (linum-mode)
             (whitespace-mode)
             (visual-line-mode)
             (setq tab-width 4)))
