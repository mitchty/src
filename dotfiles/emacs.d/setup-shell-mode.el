(autoload 'shell-mode "shell-mode" "mode for shell stuff" t)

(add-to-list 'auto-mode-alist '("\\.[bazk]*sh$" . shell-mode))
(add-to-list 'auto-mode-alist '("\\.*shrc$" . shell-mode))

(add-hook 'shell-mode-hook
          '(lambda ()
             (autopair-mode)
             (whitespace-mode)
             (visual-line-mode)
             (setq indent-tabs-mode nil)
             (setq tab-width 2)))
