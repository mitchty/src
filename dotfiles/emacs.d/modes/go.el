;;-*-mode: emacs-lisp; coding: utf-8;-*-

(add-hook 'go-mode-hook '(lambda ()
                           (add-hook 'before-save-hook #'gofmt-before-save)
                           (autopair-mode)
                           (auto-complete)
                           (hl-line-mode)
                           (visual-line-mode)
                           (whitespace-mode)
                           (setq tab-width 8)
                           ))
