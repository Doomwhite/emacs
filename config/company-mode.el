(use-package company
  :ensure t
  :commands (global-company-mode)
  :init
  (add-hook 'elpaca-after-init-hook  'global-company-mode)
  :custom
  (company-tooltip-align-annotations 't)
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.1))
