(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(gcmh which-key evil-visualstar general persp-mode restart-emacs dashboard ido-completing-read+ smex ido-vertical-mode centered-window catppuccin-theme toggle-term projectile web-mode markdown-ts-mode zig-mode nix-mode rustic rust-mode autothemer company evil-mc evil-collection evil-surround evil vterm))
 '(safe-local-variable-values
   '((eval ignore-errors
           (push
            '("Tests" "(\\(\\<ert-deftest\\)\\>\\s *\\(\\(?:\\sw\\|\\s_\\)+\\)?" 2)
            imenu-generic-expression))
     (eval progn
           (pp-buffer)
           (indent-buffer)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-tooltip ((t (:background "black" :foreground "#fff"))))
 '(company-tooltip-selection ((t (:background "#555" :foreground "#fff")))))
