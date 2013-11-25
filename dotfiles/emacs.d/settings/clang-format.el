;;-*-mode: emacs-lisp; coding: utf-8;-*-

(when osx-p
  (load "~/.emacs.d/misc/clang-format.el")
  (global-set-key [C-M-tab] 'clang-format-region)
  (setq exec-path
        (append exec-path
                '("/Users/mitch/homebrew/Cellar/llvm34/HEAD/lib/llvm-3.4/bin"))))
