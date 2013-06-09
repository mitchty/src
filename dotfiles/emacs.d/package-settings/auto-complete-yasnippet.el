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

;; Without this tab in any emacs terminal/shell mode will fail because yas is crazy
(add-hook 'term-mode-hook
          (lambda() (yas-minor-mode -1)))
