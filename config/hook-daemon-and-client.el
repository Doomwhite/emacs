(add-hook 'after-make-frame-functions
  (lambda (frame)
      (with-selected-frame frame
         (update-scroll-keybinding)
         (load-selected-theme)
         (toggle-line-numbers)
         (toggle-truncated-lines))))
