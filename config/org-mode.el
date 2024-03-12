(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

(use-package ob-mermaid
  :after org)

(electric-indent-mode -1)
(setq org-edit-src-content-indentation 2)

(require 'org-tempo)

(setq org-cycle-inline-images-display t)
