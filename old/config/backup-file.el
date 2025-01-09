;; Not working
;; (setq backup-directory-alist `(("." . "~/.config/emacs/backups")))

(setq backup-by-copying t)

(setq delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)
