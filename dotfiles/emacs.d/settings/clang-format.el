;;-*-mode: emacs-lisp; coding: utf-8;-*-

(load "/Library/Caches/Homebrew/llvm34--clang--git/tools/clang-format/clang-format.el")
(setq exec-path
      (append exec-path
              '("/Users/mitch/homebrew/Cellar/llvm34/HEAD/lib/llvm-3.4/bin")))
(global-set-key [C-M-tab] 'clang-format-region)
