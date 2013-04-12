;-*-mode: emacs-lisp-mode; coding: utf-8;-*-

(autoload 'ruby-mode "ruby-mode" "mode for Ruby formatted stuff" t)

(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\\(Vagrant\|Rake\|Gem\)file$" . ruby-mode))

(add-hook 'ruby-mode-hook
          '(lambda ()
             (autopair-mode)
             (whitespace-mode)
             (ruby-end-mode)
             (flymake-ruby-load)
             (visual-line-mode)
             (setq indent-tabs-mode nil)
             (setq tab-width 2)))
