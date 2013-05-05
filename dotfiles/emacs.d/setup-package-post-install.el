;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; What to run after emacs is up/packages loaded
(add-hook 'after-init-hook '(lambda ()
  ;; Hide the nonsense compile/message windows
  (delete-other-windows)

  ;; expand region is awesome for selecting ever increasing regions.
  (global-set-key (kbd "C-]") 'er/expand-region)

  ;; autopair, its awesome for non lisps and ()'s []'s etc...
  (require 'autopair nil 'noerror)
  (setq autopair-blink 'nil)

  ;; flymake setup, highlighting is annoying, so underline things instead
  (custom-set-faces
   '(flymake-errline ((((class color)) (:underline "red"))))
    '(flymake-warnline ((((class color)) (:underline "yellow")))))

  ;; Don't clobber minibuffer text, use help-at-pt to overlay
  (setq help-at-pt-display-when-idle '(flymake-overlay))

  ;; use gtk-ide for my color theme, solarized has... issues.
  ;; aka with it setup, even from git, it seems to crash
  ;; connections with emacsclient due to some face issue.
  ;; so eff it, ignore the thing. TODO: find out how/why
  ;; emacs segv's on linux/osx with it on, but i'm lazy prolly won't
  (color-theme-initialize)
  (color-theme-gtk-ide)

  ;; fixup multi-term theme support since it doesn't work sanely always
  (setq term-default-bg-color (face-background 'default))
  (setq term-default-fg-color (face-foreground 'default))

  ;; use ido mode all the time
  (ido-mode t)

  ;; make magit mode simpler to use
  (global-set-key (kbd "C-x m") 'magit-status)

  ;; setup uniquify for buffer names
  (require 'uniquify)
  (setq uniquify-buffer-name-style 'post-forward)

  ;; setup tramp for use
  (require 'tramp)
  (load "setup-tramp")

  ;; auto complete setup
  (require 'auto-complete-config)
  (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")

  ;; Define a common/default(ish) set of mode settings.
  ;; I mostly use the same settings everywhere so simplify.
  ;; Autopair mode would be in here if the lisp modes didn't have
  ;; better
  (setq mode-common-defaults '(
                              (auto-complete-mode)
                              (whitespace-mode)
                              (hl-line-mode)
                              (visual-line-mode)
                              (setq indent-tabs-mode nil)
                              (setq tab-width 2)
                              ))

  ;; load/setup mode hook file(s)
  (mapcar 'load-file (directory-files "~/.emacs.d/modes" t ".*.el$"))

  ;; Fill column setup for things
  (require 'fill-column-indicator)
  (setq fci-rule-character " ")
  (setq fci-rule-width 1)
  (setq fci-rule-use-dashes 0.5)
  (setq fci-rule-color "darkred")

  ;; multi-term only on non-windows, stupid windows command line
  (unless mswindows-p (load "setup-multi-term"))

  ;; Update non-edited files changed on disk automatically
  (setq global-auto-revert-mode t)

  ;; Setup yasnippet
;;  (require 'yasnippet)
;;  (setq yas/trigger-key (kbd "C-c <kp-multiply>"))
;;  (yas/initialize)

  ;; oh ya sure you betcha SNIPPETS
;;  (setq yas/root-directory '("~/.emacs.d/yasnippet"))
;;  (mapc 'yas/load-directory yas-root-directory)

  ;; Now that yasnippets loaded and auto-complete lets setup ac for snippets
;;  (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
;;  (add-to-list 'ac-modes 'objc-mode)
))
