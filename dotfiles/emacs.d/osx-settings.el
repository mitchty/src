; Use Menlo for our font on osx
; Monaco is great, but the Menlo family is better..ish
; whatever, i like it
(progn (set-default-font "Menlo 14"))

; Make full screen easier to use
(global-set-key (kbd "C-x \\") 'ns-toggle-fullscreen)
