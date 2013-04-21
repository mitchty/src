;-*-mode: emacs-lisp-mode; coding: utf-8;-*-

; What to run after emacs is up/packages loaded
(add-hook 'after-init-hook '(lambda ()
  ; Hide the nonsense compile/message windows
  (delete-other-windows)

  ; customizations for shit loaded
  (global-set-key (kbd "C-]") 'er/expand-region)

  ; autopair
  (require 'autopair nil 'noerror)
  (setq autopair-blink 'nil)

	; flymake setup, highlighting is annoying, so underline things instead
	(custom-set-faces
	 '(flymake-errline ((((class color)) (:underline "red"))))
	 '(flymake-warnline ((((class color)) (:underline "yellow")))))

  ; Don't clobber minibuffer text, use help-at-pt to overlay
	(setq help-at-pt-display-when-idle '(flymake-overlay))

	; use solarized for my color theme
	(color-theme-initialize)
  (color-theme-gtk-ide)

  ; fixup multi-term theme support since it doesn't work sanely always
  (setq term-default-bg-color (face-background 'default))
  (setq term-default-fg-color (face-foreground 'default))

	; use ido mode all the time
	(ido-mode t)

	; make magit mode simpler to use
	(global-set-key (kbd "C-x m") 'magit-status)

	; setup uniquify for buffer names
	(require 'uniquify)
	(setq uniquify-buffer-name-style 'post-forward)

  ; setup tramp for use
	(require 'tramp)
  (load "setup-tramp")

  ; auto complete setup
;  (require 'auto-complete-config)
;	(add-to-list 'ac-dictionary-directories (chomp (concat (getenv "HOME") "/.emacs.d" "/ac-dict")))

  ; load/setup mode hook file(s)
  (mapcar 'load-file (directory-files "~/.emacs.d" t "setup.*mode.el$"))

  ; Fill column setup for things
  (require 'fill-column-indicator)
  (setq fci-rule-character " ")
  (setq fci-rule-width 1)
  (setq fci-rule-use-dashes 0.5)
  (setq fci-rule-color "darkred")

  ; multi-term only on non-windows, stupid windows command line
  (unless mswindows-p (load "setup-multi-term"))

  ; Update non-edited files changed on disk automatically
  (setq global-auto-revert-mode t)
))
