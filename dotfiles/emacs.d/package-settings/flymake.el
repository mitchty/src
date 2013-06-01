;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; flymake setup, highlighting is annoying, so underline things instead
(custom-set-faces
 '(magit-item-highlight ((t nil)))
 '(flymake-errline ((((class color)) (:underline "red"))))
 '(flymake-warnline ((((class color)) (:underline "yellow")))))

;; Don't clobber minibuffer text, use help-at-pt to overlay
(setq help-at-pt-display-when-idle '(flymake-overlay))
