; Default file template definitions
; TODO move templates to the emacs directory
(add-hook 'find-file-hooks 'maybe-load-template)
(defun maybe-load-template ()
  (interactive)
  (when (and
         (string-match "\\.rb$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat (getenv "HOME") "/.src/templates/ruby.rb")))
  (when (and
         (string-match "\\.sh$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat (getenv "HOME") "/.src/templates/shell.sh")))
  (when (and
         (string-match "\\.ksh$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat (getenv "HOME") "/.src/templates/shell.ksh")))
  (when (and
         (string-match "\\.pl$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat (getenv "HOME") "/.src/templates/perl.pl")))
  (when (and
         (string-match "\\.py$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat (getenv "HOME") "/.src/templates/python.py")))
  (when (and
         (string-match "\\.pm$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file (concat (getenv "HOME") "/.src/templates/perl-module.pm")))
)
