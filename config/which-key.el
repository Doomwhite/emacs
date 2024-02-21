(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
     which-key-sort-order #'which-key-key-order-alpha
     which-key-allow-imprecise-window-fit nil
     which-key-sort-uppercase-first nil
     which-key-add-column-padding 1
     which-key-max-display-columns nil
     which-key-min-display-lines 6
     which-key-side-window-slot -10
     which-key-side-window-max-height 0.25
     which-key-idle-delay 0.2
     which-key-max-description-length 25
     which-key-allow-imprecise-window-fit nil
     which-key-separator " > " ))
