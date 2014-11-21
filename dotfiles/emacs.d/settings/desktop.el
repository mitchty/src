;;-*-mode: emacs-lisp; coding: utf-8;-*-

;; desktop saving for session sanity, add a hook into auto-save-hook
;; to save it at logical times
(require 'desktop)

(desktop-save-mode 1)

(setq desktop-restore-eager 5)
(setq desktop-path           '("/var/tmp"))
(setq desktop-dirname        "/var/tmp")
(setq desktop-base-file-name "emacs.desktop")

(defun local-desktop-save ()
  (interactive)
  (if (eq (desktop-owner) (emacs-pid))
      (desktop-save desktop-dirname)))

(add-hook 'auto-save-hook 'desktop-save-in-desktop-dir)
