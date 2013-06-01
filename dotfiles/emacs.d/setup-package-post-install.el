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
   '(magit-item-highlight ((t nil)))
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
  (if window-system
         (color-theme-hober)
         (color-theme-gtk-ide))

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

  (setq-default ac-sources '(ac-source-yasnippet ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
  (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)
  (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (add-hook 'ruby-mode-hook 'ac-ruby-mode-setup)

  (add-hook 'auto-complete-mode-hook 'ac-common-setup)
  (global-auto-complete-mode t)
  (add-to-list 'ac-modes 'objc-mode)


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
  (require 'yasnippet)
  (setq my-yasnippet-dir "~/.emacs.d/yasnippet")
	(unless (file-accessible-directory-p my-yasnippet-dir)
		(make-directory my-yasnippet-dir t))

  ;; oh ja sure you betcha yasnippets kthxbai
  (setq yas/root-directory '("~/.emacs.d/yasnippet"))
  (mapc 'yas/load-directory '("~/.emacs.d/yasnippet"))

  ;; Now that yasnippets loaded and auto-complete lets setup ac for snippets
  (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (add-to-list 'ac-modes 'objc-mode)
  (yas--initialize)

  ;; Without this tab in any emacs terminal/shell mode will fail because yas is crazy
  (add-hook 'term-mode-hook
						(lambda() (yas-minor-mode -1)))

  ;; setup anything mode for xcode a like pragma stuff
  (require 'anything)
  (require 'anything-config)

  (defvar anything-c-source-objc-headline
  '((name . "Objective-C Headline")
    (headline  "^[-+@]\\|^#pragma mark")))

  (defun objc-headline ()
    (interactive)
    ;; Set to 500 so it is displayed even if all methods are not narrowed down.
    (let ((anything-candidate-number-limit 500))
      (anything-other-buffer '(anything-c-source-objc-headline)
                 "*ObjC Headline*")))

  (global-set-key "\C-xp" 'objc-headline)
))
