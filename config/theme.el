(defun load-selected-theme ()

  (interactive)
  (load-theme 'kanagawa t)
  ;; (autothemer--current-theme 'kanagawa)

)

(use-package catppuccin-theme)

;; (use-package kanagawa-theme)

(use-package autothemer 
 :init
 (add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
 (load-selected-theme))

(use-package doom-themes)
