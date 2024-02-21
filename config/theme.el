(defun load-selected-theme ()
  (load-theme 'kanagawa t)
)

;; (use-package catppuccin-theme)

(use-package kanagawa-theme
  :config
  (load-selected-theme))

;; (add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
