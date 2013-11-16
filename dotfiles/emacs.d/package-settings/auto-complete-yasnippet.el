;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; Combined because of ordering insurance, its picky/tricky

;; auto-complete setup (boring bits)
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")

(setq-default ac-sources '(ac-source-yasnippet ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
(add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)
(add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
(add-hook 'ruby-mode-hook 'ac-ruby-mode-setup)

(add-hook 'auto-complete-mode-hook 'ac-common-setup)
(global-auto-complete-mode t)
(add-to-list 'ac-modes 'objc-mode)

;; Setup yasnippet
(require 'yasnippet)
(setq my-yasnippet-dir "~/.emacs.d/yasnippet")
(unless (file-accessible-directory-p my-yasnippet-dir)
  (make-directory my-yasnippet-dir t))

;; oh ja sure you betcha yasnippets kthxbai
(setq yas/root-directory '("~/.emacs.d/yasnippet"))
(mapc 'yas/load-directory '("~/.emacs.d/yasnippet"))

;; Now that yasnippets loaded and auto-complete lets setup ac for snippets
(add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
(add-to-list 'ac-modes 'objc-mode)
  (yas--initialize)

;; Without this tab in any emacs terminal/shell mode will fail because
;; yas is crazy
(add-hook 'term-mode-hook
          (lambda() (yas-minor-mode -1)))

(define-key yas-keymap (kbd "<return>") 'yas/exit-all-snippets)

(defun yas/goto-end-of-active-field ()
  (interactive)
  (let* ((snippet (car (yas--snippets-at-point)))
        (position (yas--field-end (yas--snippet-active-field snippet))))
    (if (= (point) position)
        (move-end-of-line 1)
      (goto-char position))))

(defun yas/goto-start-of-active-field ()
  (interactive)
  (let* ((snippet (car (yas--snippets-at-point)))
        (position (yas--field-start (yas--snippet-active-field snippet))))
    (if (= (point) position)
        (move-beginning-of-line 1)
      (goto-char position))))

;; Make the active field behave more emacsy
(define-key yas-keymap (kbd "C-e") 'yas/goto-end-of-active-field)
(define-key yas-keymap (kbd "C-a") 'yas/goto-start-of-active-field)

;; Use ido for completing things the gui selector is shit, ido is
;; mucho better.
(setq yas-prompt-functions '(yas/ido-prompt yas/completing-prompt))

;; Wrap around the region in emacs
(setq yas-wrap-around-region t)
