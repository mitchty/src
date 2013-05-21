;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; Don't setup x windows paste behavior under osx
(unless osx-p
  (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
  (setq x-select-enable-clipboard t))
