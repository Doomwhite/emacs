(defun print-current-directory ()
  "Print the current directory in the minibuffer."
  (interactive)
  (message "Current directory: %s" default-directory))

(defun update-scroll-keybinding (&optional frame)
       "Update keybindings in evil-normal-state-map and evil-visual-state-map based on the current window height."
       (interactive)
       ;; Calculate the value based on the current window height
       (let ((x-value (ceiling (/ (float (window-height)) (* 2.2 1.2)))))
          ;; Define the keybindings using the calculated value and 'k'
          (define-key evil-normal-state-map (kbd "C-u") (kbd (format "%dk" x-value)))
          (define-key evil-visual-state-map (kbd "C-u") (kbd (format "%dk" x-value)))
          (define-key evil-normal-state-map (kbd "C-d") (kbd (format "%dj" x-value)))
          (define-key evil-visual-state-map (kbd "C-d") (kbd (format "%dj" x-value)))
   )
)

(add-hook 'window-size-change-functions #'update-scroll-keybinding)

(defun toggle-shell()
  (interactive)
  (if (string= (buffer-name) "*shell*")
      (switch-to-buffer (other-buffer))
    (shell)))

(use-package general
  :config
  (general-evil-setup)

  ;; Leader key
  (general-create-definer dw/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix  "SPC"
    :global-prefix "M-SPC")

  (dw/leader-keys
    "q" '(kill-this-buffer :wk "Quit")
    "Q" '(kill-this-buffer :wk "Quit"))

  (dw/leader-keys
    "SPC" '(:ignore t :wk "2nd layer"))

  (dw/leader-keys
    "." '(:ignore t :wk "Current directory")
    ". d" '(print-current-directory :wk "Prints the current directory")
    ". r" '(update-scroll-keybinding :wk "Sets the scrolling settings by window size")
    ". n" '(centered-window-mode :wk "Sets the centered window mode"))

  (dw/leader-keys
    "f" '(:ignore t :wk "Filesystem")
    "f s" '(save-buffer :wk "Save file")
    "f S" '(save-some-buffers :wk "Save all files")
    "f f" '(find-file :wk "Find file")
    "f t" '(find-grep-dired :wk "Find text")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config"))

  (dw/leader-keys
    "b" '(:ignore t :wk "Buffer")
    "b b" '(switch-to-buffer :wk "Switch buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-this-buffer :wk "Kill this buffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer"))

  (dw/leader-keys
    "e" '(:ignore t :wk "Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region"))

  (dw/leader-keys
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe variable")
    "h r r" '((lambda () (interactive)
                (load-file "~/.config/emacs/init.el")
                (ignore (elpaca-process-queues)))
              :wk "Reload emacs config"))

  (dw/leader-keys 
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(visual-line-mode :wk "Toggle truncated lines"))

  (dw/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))

  ;; g
  (general-create-definer dw/g-keys
     :states '(normal insert visual emacs)
     :keymaps 'override
     :prefix  "g"
     :global-prefix "M-g")

  ;; Comment line
  (dw/g-keys "c" '(comment-line :wk "Comment"))

  ;; semicollon
  (general-create-definer dw/semicollon-keys
     :states '(normal insert visual emacs)
     :keymaps 'override
     :prefix  ";"
     :global-prefix "M-;")

  (dw/semicollon-keys
    "q" '(kill-this-buffer :wk "Kill this buffer")
    "e" '(treemacs-select-window :wk "Selects treemacs")
    "E" '(treemacs :wk "Opens treemacs")
    "z" '(kill-emacs :wk "Reload buffer"))

  ;; Ctrl keys
  (define-key evil-normal-state-map (kbd "C-t") 'toggle-shell)

  ;; Makes Escape quit prompts (Minibuffer Escape)
  (global-set-key [escape] 'keyboard-escape-quit)

  ;; Basic movement bindings
  (define-key evil-normal-state-map (kbd "H") 'beginning-of-line-text)
  (define-key evil-visual-state-map (kbd "H") 'beginning-of-line-text)
  (define-key evil-normal-state-map (kbd "L") 'end-of-line)
  (define-key evil-visual-state-map (kbd "L") 'end-of-line)
  (define-key evil-normal-state-map (kbd "K") 'evil-backward-paragraph)
  (define-key evil-visual-state-map (kbd "K") 'evil-backward-paragraph)
  (define-key evil-normal-state-map (kbd "J") 'evil-forward-paragraph)
  (define-key evil-visual-state-map (kbd "J") 'evil-forward-paragraph)
)
