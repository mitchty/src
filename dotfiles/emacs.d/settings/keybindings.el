;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; show what is being typed quicker
(custom-set-variables '(echo-keystrokes 0.1))

;; Let shift+arrow keys change panes
(require 'windmove)
(windmove-default-keybindings)

;; Make goto-line a bit easier to use
(global-set-key (kbd "C-x g") 'goto-line)
