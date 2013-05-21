;;-*-mode: Emacs-Lisp; coding: utf-8;-*-

(add-to-list 'auto-mode-alist '("\\.org" . org-mode))

(add-hook 'org-mode-hook
          (lambda ()
            (ispell-minor-mode)
            (visual-line-mode)
            (whitespace-mode)
            (hl-line-mode)
            ))
