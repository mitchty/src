;;-*-mode: emacs-lisp; coding: utf-8;-*-
(custom-set-variables
 '(haskell-process-type 'ghci)
 '(haskell-process-args-ghci '())
 '(haskell-notify-p t)
 '(haskell-stylish-on-save nil)
 '(haskell-tags-on-save t)
 '(haskell-process-suggest-remove-import-lines t)
 '(haskell-process-auto-import-loaded-modules t)
 '(haskell-process-log t)
 '(haskell-process-reload-with-fbytecode nil)
 '(haskell-process-use-presentation-mode t)
 '(haskell-interactive-mode-include-file-name nil)
 '(haskell-interactive-mode-eval-pretty nil)
;; '(shm-use-hdevtools t)
;; '(shm-use-presentation-mode t)
;; '(shm-auto-insert-skeletons t)
;; '(shm-auto-insert-bangs t)
 '(haskell-process-show-debug-tips nil)
 '(haskell-process-suggest-hoogle-imports nil)
 '(haskell-process-suggest-haskell-docs-imports t))

(defun unicode-symbol (name)
   "Translate a symbolic name for a Unicode character -- e.g., LEFT-ARROW
 or GREATER-THAN into an actual Unicode character code. "
   (decode-char 'ucs (case name
                       (left-arrow 8592)
                       (up-arrow 8593)
                       (right-arrow 8594)
                       (down-arrow 8595)
                       (double-vertical-bar #X2551)
                       (equal #X003d)
                       (not-equal #X2260)
                       (identical #X2261)
                       (not-identical #X2262)
                       (less-than #X003c)
                       (greater-than #X003e)
                       (less-than-or-equal-to #X2264)
                       (greater-than-or-equal-to #X2265)
                       (logical-and #X2227)
                       (logical-or #X2228)
                       (logical-neg #X00AC)
                       ('nil #X2205)
                       (horizontal-ellipsis #X2026)
                       (double-exclamation #X203C)
                       (prime #X2032)
                       (double-prime #X2033)
                       (for-all #X2200)
                       (there-exists #X2203)
                       (element-of #X2208)
                       (square-root #X221A)
                       (squared #X00B2)
                       (cubed #X00B3)
                       (lambda #X03BB)
                       (alpha #X03B1)
                       (beta #X03B2)
                       (gamma #X03B3)
                       (delta #X03B4))))

(defun substitute-pattern-with-unicode (pattern symbol)
    "Add a font lock hook to replace the matched part of PATTERN with the
     Unicode symbol SYMBOL looked up with UNICODE-SYMBOL."
    (font-lock-add-keywords
    nil `((,pattern
           (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                     ,(unicode-symbol symbol)
                                     'decompose-region)
                             nil))))))

(defun substitute-patterns-with-unicode (patterns)
   "Call SUBSTITUTE-PATTERN-WITH-UNICODE repeatedly."
   (mapcar #'(lambda (x)
               (substitute-pattern-with-unicode (car x)
                                                (cdr x)))
           patterns))

(defun haskell-unicode ()
 (substitute-patterns-with-unicode
  (list (cons "\\(<-\\)" 'left-arrow)
        (cons "\\(->\\)" 'right-arrow)
        (cons "\\(==\\)" 'identical)
        (cons "\\(/=\\)" 'not-identical)
        (cons "\\(()\\)" 'nil)
        (cons "\\<\\(sqrt\\)\\>" 'square-root)
        (cons "\\(&&\\)" 'logical-and)
        (cons "\\(||\\)" 'logical-or)
        (cons "\\<\\(not\\)\\>" 'logical-neg)
        (cons "\\(>\\)\\[^=\\]" 'greater-than)
        (cons "\\(<\\)\\[^=\\]" 'less-than)
        (cons "\\(>=\\)" 'greater-than-or-equal-to)
        (cons "\\(<=\\)" 'less-than-or-equal-to)
        (cons "\\<\\(alpha\\)\\>" 'alpha)
        (cons "\\<\\(beta\\)\\>" 'beta)
        (cons "\\<\\(gamma\\)\\>" 'gamma)
        (cons "\\<\\(delta\\)\\>" 'delta)
        (cons "\\(''\\)" 'double-prime)
        (cons "\\('\\)" 'prime)
        (cons "\\(!!\\)" 'double-exclamation)
        (cons "\\(\\.\\.\\)" 'horizontal-ellipsis))))

(add-hook 'haskell-mode-hook 'haskell-unicode)

(setq haskell-complete-module-preferred
      '("Data.ByteString"
        "Data.ByteString.Lazy"
        "Data.Function"
        "Data.List"
        "Data.Map"
        "Data.Maybe"
        "Data.Monoid"
        "Data.Ord"))

(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)

(add-hook
 'haskell-mode-hook
 '(lambda ()
    (ghc-init)
    (setq haskell-interactive-mode-eval-mode 'haskell-mode)
    (interactive-haskell-mode)
    (custom-set-variables
     '(haskell-process-suggest-remove-import-lines t)
     '(haskell-process-auto-import-loaded-modules t)
     '(haskell-process-log t)
     '(haskell-tags-on-save t)
     '(haskell-process-type 'cabal-repl)
     )
    (define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
    (define-key haskell-mode-map (kbd "C-`") 'haskell-interactive-bring)
    (define-key haskell-mode-map (kbd "C-c C-n C-t") 'haskell-process-do-type)
    (define-key haskell-mode-map (kbd "C-c C-n C-i") 'haskell-process-do-info)
    (define-key haskell-mode-map (kbd "C-c C-n C-c") 'haskell-process-cabal-build)
    (define-key haskell-mode-map (kbd "C-c C-n c") 'haskell-process-cabal)
    (define-key haskell-mode-map (kbd "SPC") 'haskell-mode-contextual-space)
    (define-key haskell-mode-map (kbd "M-." 'haskell-mode-jump-to-def-or-tag))
    (define-key haskell-mode-map [f8] 'haskell-navigate-imports))
    )

(add-hook 'cabal-mode-hook (lambda ()
  (define-key haskell-cabal-mode-map (kbd "C-`") 'haskell-interactive-bring)
  (define-key haskell-cabal-mode-map (kbd "C-c C-k") 'haskell-interactive-ode-clear)
  (define-key haskell-cabal-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
  (define-key haskell-cabal-mode-map (kbd "C-c c") 'haskell-process-cabal)))
;;    (stylish-haskell-mode)
;;    (define-key haskell-mode-map
;;      (kbd "C-x C-s") 'haskell-mode-save-buffer)
;;    (add-to-list 'align-rules-list
;;                 '(haskell-types
;;                   (regexp . "\\(\\s-+\\)\\(::\\|∷\\)\\s-+")
;;                   (modes quote (haskell-mode literate-haskell-mode))))
;;    (add-to-list 'align-rules-list
;;                 '(haskell-assignment
;;                   (regexp . "\\(\\s-+\\)=\\s-+")
;;                   (modes quote (haskell-mode literate-haskell-mode))))
;;    (add-to-list 'align-rules-list
;;                 '(haskell-arrows
;;                   (regexp . "\\(\\s-+\\)\\(->\\|→\\)\\s-+")
;;                   (modes quote (haskell-mode literate-haskell-mode))))
;;    (add-to-list 'align-rules-list
;;                 '(haskell-left-arrows
;;                   (regexp . "\\(\\s-+\\)\\(<-\\|←\\)\\s-+")
;;                   (modes quote (haskell-mode literate-haskell-mode))))
;;    ))

;; MOVE ME
(global-set-key (kbd "C-x a r") 'align-regexp)
