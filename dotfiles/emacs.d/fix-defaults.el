;-*-mode: emacs-lisp; coding: utf-8;-*-

; show what is being typed quicker
(custom-set-variables '(echo-keystrokes 0.1))

; y/n is good enough
(defalias 'yes-or-no-p 'y-or-n-p)

; utf8 by default
(custom-set-variables '(locale-coding-system 'utf-8))
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

; if I selected it, deleting it is OK kthxbai
(delete-selection-mode 1)

; be more like vi, display line/col always
(custom-set-variables '(line-number-mode t))
(custom-set-variables '(column-number-mode t))

; 80 char lines not 72
(custom-set-variables '(fill-column 80))

; ok, double spacing after a period for sentences
; is fucking archaic, we don't use typewriters any longer
(set-default 'sentence-end-double-space nil)

; highlight the current line
(global-hl-line-mode 1)

; highlight parens n stuff
(show-paren-mode)

; Tell the gc to be more aggressive
(custom-set-variables '(garbage-collection-messages t))
(custom-set-variables '(gc-cons-threshold (* 12 1024 1024)))

; What emacs thinks a sentence ending is, make it less derp.
(custom-set-variables '(sentence-end "[.?!][]\"')]*\\($\\|\t\\| \\)[ \t\n]*"))
(custom-set-variables '(sentence-end-double-space nil))

; Default major mode is just text
(custom-set-variables '(default-major-mode 'text-mode))

; Tabs suck, no
(custom-set-variables '(default-tab-width 2))

; Always remove trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

; Setup whitespace mode to highlight tabs and over 80 char spaces
(require 'whitespace)
(setq whitespace-line-column 80
      whitespace-style '(face tab-mark tabs trailing lines-tail))

(set-face-attribute 'whitespace-tab nil
                    :foreground "#2075c7"
                    :background "lightgrey")

(set-face-attribute 'whitespace-line nil
                    :foreground "#2075c7"
                    :background "lightgrey")

; Make goto-line a bit easier to use
(global-set-key (kbd "C-x g") 'goto-line)

; Don't clobber minibuffer text
(custom-set-variables '(help-at-pt-timer-delay 0.9))

; Auto chmod u+x on scripts, because why wouldn't you?
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

; Set the time in the mode line
(display-time-mode)

; Ok backup files are annoying
(setq make-backup-files nil)
(setq auto-save-default nil)

; Let shift+arrow keys change panes
(windmove-default-keybindings)
