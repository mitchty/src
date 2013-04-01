; show what is being typed quicker
(setq echo-keystrokes 0.1)

; y/n is good enough
(defalias 'yes-or-no-p 'y-or-n-p)

; utf8 by default
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

; if I selected it, deleting it is OK kthxbai
(delete-selection-mode 1)

; be more like vi, display line/col always
(setq line-number-mode t)
(setq column-number-mode t)

; 80 char lines not 72
(setq fill-column 80)

; ok, double spacing after a period for sentences
; is fucking archaic, we don't use typewriters any longer
(set-default 'sentence-end-double-space nil)

; highlight the current line
(global-hl-line-mode 1)

; highlight parens n stuff
(show-paren-mode)

; Tell the gc to be more aggressive
(setq garbage-collection-messages t)
(setq gc-cons-threshold (* 12 1024 1024))

; What emacs thinks a sentence ending is, make it less derp.
(setq sentence-end "[.?!][]\"')]*\\($\\|\t\\| \\)[ \t\n]*")
(setq sentence-end-double-space nil)

; Default major mode is just text
(setq default-major-mode 'text-mode)

; Tabs suck, no
(setq default-tab-width 2)

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
(setq help-at-pt-timer-delay 0.9)

; Auto chmod u+x on scripts, because why wouldn't you?
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
