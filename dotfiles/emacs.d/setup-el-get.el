;-*-mode: emacs-lisp; coding: utf-8;-*-

; Now that emacs 24 doesn't suck, lets use el-get
; Install el-get if its not present
(defvar ell-get-basedir (format "%s/%s" load-base "el-get"))
(defvar ell-get-dir (format "%s/%s" ell-get-basedir "el-get"))
(defvar ell-get-url
  "https://raw.github.com/dimitri/el-get/master/el-get-install.el")

(add-to-list 'load-path ell-get-dir)

(unless (file-accessible-directory-p ell-get-dir)
	(url-retrieve ell-get-url
								(lambda (s)
									(goto-char (point-max))
									(eval-print-last-sexp))))

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
    (url-retrieve-synchronously ell-get-url
      (lambda (s)
        (end-of-buffer)
        (eval-print-last-sexp)))))

(setq my:el-get-packages
      '(
yasnippet
flymake-cursor
flymake-ruby
expand-region
auto-complete
auto-complete-clang
magit
markdown-mode
smex
fill-column-indicator
ruby-end
multi-term
autopair
dropdown-list
        ))

(el-get 'sync my:el-get-packages)
