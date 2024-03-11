(setq find-program (expand-file-name "shims/find.exe" user-emacs-directory))
(use-package rg
  :config
  (rg-enable-default-bindings))
