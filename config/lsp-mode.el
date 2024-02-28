(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  ;; (setq lsp-keymap-prefix "C-c l")
  (setq lsp-clients-angular-language-server-command
   '("node"
     "/usr/lib/node_modules/@angular/language-server"
     "--ngProbeLocations"
     "/usr/lib/node_modules"
     "--tsProbeLocations"
     "/usr/lib/node_modules"
     "--stdio"))
  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;;(add-hook 'prog-mode-hook' 'lsp)

;; lsp-ui
(use-package lsp-ui
  :commands lsp-ui-mode)

;; if you are helm user
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)

;; if you are ivy user
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; (use-package dap-LANGUAGE) to load the dap adapter for your language
(use-package zig-mode)
