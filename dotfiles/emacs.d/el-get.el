;-*-mode: emacs-lisp; coding: utf-8;-*-

(defvar ell-get-url
  "https://raw.github.com/dimitri/el-get/master/el-get-install.el")

; Now that emacs 24 doesn't suck, lets use el-get
; Install el-get if its not present
(defvar ell-get-basedir "~/.emacs.d/el-get")
(defvar ell-get-dir "~/.emacs.d/el-get/el-get")
(defvar ell-get-recipedir "~/.emacs.d/el-get/el-get/recipes")
(defvar ell-get-emacswiki "~/.emacs.d/el-get/emacswiki")

(add-to-list 'load-path ell-get-dir)

(unless (file-accessible-directory-p ell-get-dir)
  (url-retrieve ell-get-url
                (lambda (s)
                  (let (el-get-master-branch)
                  (goto-char (point-max))
                  (eval-print-last-sexp)))))

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously ell-get-url
                                  (lambda (s)
                                    (let (el-get-master-branch)
                                      (goto-char (point-max))
                                      (eval-print-last-sexp))))
    (el-get-emacswiki-refresh)
    (el-get-emacswiki-build-local-recipes)
    (package-refresh-contents)))

(el-get 'sync)
;(el-get-emacswiki-refresh ell-get-emacswiki)

(add-to-list 'el-get-recipe-path ell-get-recipedir)

;(require 'el-get-emacswiki)

(setq el-get-verbose t)

(setq el-get-sources
      '((:name el-get :branch "master")))

(setq all-the-packages
  (append
    '(yasnippet flymake-cursor flymake-ruby expand-region auto-complete
      auto-complete-clang magit markdown-mode smex fill-column-indicator
      ruby-end multi-term autopair dropdown-list popup org-mode
      color-theme markdown-mode perl-completion anything workgroups
      )
    (mapcar 'el-get-as-symbol (mapcar 'el-get-source-name el-get-sources))))

(el-get 'sync all-the-packages)
