;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; Don't setup x windows paste behavior under osx
(unless osx-p
  (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
  (setq scroll-bar-mode-explicit t)
  (setq x-select-enable-clipboard t))

;; Mouse mode is ok to use
(mouse-wheel-mode t)
(mwheel-install)

;; Nuke the stupid toolbar, put the scroll bar on the right (sic) side
(tool-bar-mode -1)
(set-scroll-bar-mode 'right)
