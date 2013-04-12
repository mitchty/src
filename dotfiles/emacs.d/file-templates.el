;-*-mode: emacs-lisp-mode; coding: utf-8;-*-

; Default file template definitions
; TODO move templates to the emacs directory
(add-hook 'find-file-hooks 'maybe-load-template)

(setq template-file-prefix (concat (getenv "HOME") "/.emacs.d/templates"))

(defun maybe-load-template ()
  (interactive)
  (when (and
         (string-match "\\.rb$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat template-file-prefix "/ruby.rb")))
  (when (and
         (string-match "\\.sh$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat template-file-prefix "/shell.sh")))
  (when (and
         (string-match "\\.ksh$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat template-file-prefix "/shell.ksh")))
  (when (and
         (string-match "\\.pl$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat template-file-prefix "/perl.pl")))
  (when (and
         (string-match "\\.py$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat template-file-prefix "/python.py")))
  (when (and
         (string-match "\\.pm$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat template-file-prefix "/perl-module.pm")))
  (when (and
         (string-match "\\.el$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat template-file-prefix "/elisp.el")))
)
