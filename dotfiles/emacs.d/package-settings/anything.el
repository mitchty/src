;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; setup anything mode for xcode alike pragma stuff
(require 'anything)
(require 'anything-config)

(defvar anything-c-source-objc-headline
  '((name . "Objective-C Headline")
    (headline  "^[-+@]\\|^#pragma mark")))

(defun objc-headline ()
	(interactive)
	;; Set limit to 500 so we get a display even if all methods are not narrowed down yet
	(let ((anything-candidate-number-limit 500))
		(anything-other-buffer '(anything-c-source-objc-headline)
													 "*ObjC Headline*")))

(global-set-key "\C-xp" 'objc-headline)
