;;-*-mode: emacs-lisp; coding: utf-8;-*-

(when window-system
	;; Don't setup x windows paste behavior under osx
	;; setup fonts as appropriate
	(cond (osx-p
				 ;; osx nonsense
				 (set-face-attribute 'default nil :font "Menlo 14"))

				(t

				 ;; assuming linux for the rest for now, no need for windows
				 (set-face-attribute 'default nil :font "Monaco 10")
				 (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
				 (setq x-select-enable-clipboard t)))
)
