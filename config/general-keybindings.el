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

(defun set-marker-W () (interactive) (evil-set-marker ?W))
(defun set-marker-E () (interactive) (evil-set-marker ?E))
(defun set-marker-R () (interactive) (evil-set-marker ?R))
(defun set-marker-S () (interactive) (evil-set-marker ?S))
(defun set-marker-D () (interactive) (evil-set-marker ?D))
(defun set-marker-F () (interactive) (evil-set-marker ?F))
(defun goto-marker-W () (interactive) (evil-goto-mark-line ?W))
(defun goto-marker-E () (interactive) (evil-goto-mark-line ?E))
(defun goto-marker-R () (interactive) (evil-goto-mark-line ?R))
(defun goto-marker-S () (interactive) (evil-goto-mark-line ?S))
(defun goto-marker-D () (interactive) (evil-goto-mark-line ?D))
(defun goto-marker-F () (interactive) (evil-goto-mark-line ?F))

(use-package general
  :config
  (general-auto-unbind-keys t)
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
    "e" '(:ignore t :wk "Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region"))

  (dw/leader-keys
    "h" '(:ignore t :wk "Help")
    "h d" '(:ignore :wk "Describe")
    "h d f" '(describe-function :wk "Function")
    "h d F" '(describe-face :wk "Face")
    "h d m" '(describe-mode :wk "Mode")
    "h d v" '(describe-variable :wk "Variable")
    "h d k" '(describe-key :wk "Mode")
    "h i" '(info :wk "Open manual")
    "h a" '(:ignore t :wk "Apropos")
    "h a a" '(apropos :wk "Apropos")
    "h a c" '(apropos-command :wk "Command")
    "h a l" '(apropos-library :wk "Library")
    "h a u" '(apropos-user-option :wk "User option")
    "h a v" '(apropos-value :wk "Value")
    "h l" '(:ignore t :wk "Load")
    ;; Won't work for some reason
    ;; "h l t" '(load-theme :wk "Theme")
    "h r" '(:ignore t :wk "Reload")
    "h r t" '(load-selected-theme :wk "Theme" )
    "h r r" '(restart-emacs :wk "Emacs config"))

  (dw/leader-keys 
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(visual-line-mode :wk "Toggle truncated lines")
    "t i" '(org-toggle-inline-images :wk "Toggle inline images"))

  (dw/leader-keys
    "w" '(:ignore t :wk "Window/Buffer management")
     ;; Buffer
    "w b" '(switch-to-buffer :wk "Switch buffer")
    "w i" '(ibuffer :wk "Ibuffer")
    "w C" '(kill-this-buffer :wk "Kill this buffer")
    "w n" '(next-buffer :wk "Next buffer")
    "w p" '(previous-buffer :wk "Previous buffer")
    "w r" '(revert-buffer :wk "Reload buffer")
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

  (dw/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d n" '(neotree-dir :wk "Open directory in neotree")
    "d p" '(peep-dired :wk "Peep-dired"))

  (dw/leader-keys 
    "o" '(:ignore t :wk "Org mode")
    "o l" '(:ignore t :wk "Link")
    "o l s" '(org-store-link :wk "Store link")
    "o l i" '(org-insert-link :wk "Insert link"))

  ;; g
  (general-create-definer dw/g-keys
     :states '(normal insert visual emacs)
     :keymaps 'override
     :prefix  "g"
     :global-prefix "M-g")

  ;; Comment line
  (dw/g-keys "c" '(comment-line :wk "Comment"))

  ;; Semicollon
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

  ;; Marks
  (general-create-definer dw/m-keys
     :states '(normal)
     :keymaps 'override
     :prefix  "m")

  (dw/leader-keys
      "m w" '(set-marker-W :wk "Set marker W")
      "m e" '(set-marker-E :wk "Set marker E")
      "m r" '(set-marker-R :wk "Set marker R")
      "m s" '(set-marker-S :wk "Set marker S")
      "m d" '(set-marker-D :wk "Set marker D")
      "m f" '(set-marker-F :wk "Set marker F"))

  (dw/m-keys
      "w" '(goto-marker-W :wk "Go to marker W")
      "e" '(goto-marker-E :wk "Go to marker E")
      "r" '(goto-marker-R :wk "Go to marker R")
      "s" '(goto-marker-S :wk "Go to marker S")
      "d" '(goto-marker-D :wk "Go to marker D")
      "f" '(goto-marker-F :wk "Go to marker F"))

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
