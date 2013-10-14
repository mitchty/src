;;-*-mode: emacs-lisp; coding: utf-8;-*-

(add-hook 'rust-mode-hook '(lambda () (interactive) (column-marker-1 80)))
(add-hook 'rust-mode-hook '(lambda ()
                           (smartparens-mode)
                           (auto-complete-mode)
                           (hl-line-mode)
                           (visual-line-mode)
                           (whitespace-mode)
                           (setq tab-width 8)
													 (flycheck-mode)
                           ))

(defun rust-run-current-buffers-file ()
  "run a command on the current file"
  (interactive)
  (shell-command
   (format "rust run %s 2>&1 | grep -v 'warning: no debug symbols in executable'"
       (shell-quote-argument (buffer-file-name))))
)

(defun rust-test-current-buffers-file ()
  "run a command on the current file"
  (interactive)
  (shell-command
   (format "rust test %s 2>&1 | grep -v 'warning: no debug symbols in executable'"
       (shell-quote-argument (buffer-file-name))))
)

(global-set-key (kbd "C-S-r") 'rust-run-current-buffers-file)
(global-set-key (kbd "C-S-t") 'rust-test-current-buffers-file)
