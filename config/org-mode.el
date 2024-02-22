(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

(electric-indent-mode -1)

(require 'org-tempo)

(setq org-cycle-inline-images-display t)
