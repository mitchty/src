;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; Mouse mode is ok to use
(mouse-wheel-mode t)
(mwheel-install)

;; Nuke the stupid toolbar, put the scroll bar on the right (sic) side
(tool-bar-mode -1)

;; Screw the scrollbar, don't need it
(scroll-bar-mode -1)

;; Also the fringe, takes up space
(fringe-mode 0)