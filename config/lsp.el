(defun efs/lsp-mode-setup ()  
  (setq lsp-headerline-breadcrumb-segment)
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init 
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui 
  :hook (lsp-mode . lsp-ui-mode)
  :custom 
  (lsp-ui-doc-position 'bottom))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config 
  (setq typescript-indent-level 2))
