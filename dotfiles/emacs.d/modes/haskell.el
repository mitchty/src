;;-*-mode: emacs-lisp; coding: utf-8;-*-

(add-to-list 'load-path "~/.emacs.d/shm/elisp")
(require 'shm)

(add-hook 'haskell-mode-hook
          '(lambda ()
             (auto-complete-mode)
             (whitespace-mode)
             (hl-line-mode)
             (visual-line-mode)
             (structured-haskell-mode)
             ))

(set-face-background 'shm-current-face "#cce8d5")
(set-face-background 'shm-quarantine-face "lemonchiffon")
