(use-package magit
  :commands magit-status)

(use-package diff-hl
  :hook ((magit-pre-refresh-hook . diff-hl-magit-pre-refresh)
         (magit-post-refresh-hook . diff-hl-magit-post-refresh))
  :init (global-diff-hl-mode))
