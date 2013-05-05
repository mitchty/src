;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; Setup whitespace mode to highlight tabs and over 80 char spaces
(require 'whitespace)

(setq whitespace-line-column 80
      whitespace-style '(face tab-mark tabs trailing lines-tail))

(set-face-attribute 'whitespace-tab nil
                    :foreground "#2075c7"
                    :background "lightgrey")

(set-face-attribute 'whitespace-line nil
                    :foreground "#2075c7"
                    :background "lightgrey")
