;;-*-mode: emacs-lisp; coding: utf-8;-*-

(when window-system
	(set-face-attribute 'default nil :foundry "apple" :family "Source Code Pro 12")
	(cond (linux-p
         (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
         (setq x-select-enable-clipboard t)
				 )
				)
	)
