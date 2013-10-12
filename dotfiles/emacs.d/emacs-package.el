;;-*-mode: emacs-lisp; coding: utf-8;-*-
(require 'package)
(setq my-packages
      '(
        flycheck
        expand-region
        auto-complete
        auto-complete-clang-async
        magit
        markdown-mode
        smex
				column-marker
        ruby-end
        multi-term
        autopair
        dropdown-list
        popup
        org-mode
        org-bullets
        org-pomodoro
        org-present
        color-theme
        markdown-mode
        perl-completion
        anything
        workgroups
        go-mode
        rust-mode
        yasnippet
        ))

(package-initialize)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives
						 '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
             '("org" . "http://orgmode.org/elpa/"))

;; TODO: maybe set an ENV var to force refresh at startup?
(when (not package-archive-contents)
  (package-refresh-contents))

(dolist (pkg my-packages)
  (when (and (not (package-installed-p pkg))
           (assoc pkg package-archive-contents))
    (package-install pkg)))

(defun package-list-unaccounted-packages ()
  "Like `package-list-packages', but shows only the packages that
  are installed and are not in `my-packages'.  Useful for
  cleaning out unwanted packages."
  (interactive)
  (package-show-package-list
   (remove-if-not (lambda (x) (and (not (memq x my-packages))
                            (not (package-built-in-p x))
                            (package-installed-p x)))
                  (mapcar 'car package-archive-contents))))
