(defun start/org-babel-tangle-config ()
  "Automatically tangle our Emacs.org config file when we save it. Credit to Emacs From Scratch for this one!"
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'start/org-babel-tangle-config)))

;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defvar elpaca-installer-version 0.6)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
      :ref nil
      :files (:defaults (:exclude "extensions"))
      :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
 (build (expand-file-name "elpaca/" elpaca-builds-directory))
 (order (cdr elpaca-order))
 (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
  (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
     ((zerop (call-process "git" nil buffer t "clone"
         (plist-get order :repo) repo)))
     ((zerop (call-process "git" nil buffer t "checkout"
         (or (plist-get order :ref) "--"))))
     (emacs (concat invocation-directory invocation-name))
     ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
         "--eval" "(byte-recompile-directory \".\" 0 'force)")))
     ((require 'elpaca))
     ((elpaca-generate-autoloads "elpaca" repo)))
      (kill-buffer buffer)
    (error "%s" (with-current-buffer buffer (buffer-string))))
((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;;When installing a package which modifies a form used at the top-level
;;(e.g. a package which adds a use-package key word),
;;use `elpaca-wait' to block until that package has been installed/configured.
;;For example:
;;(use-package general :demand t)
;;(elpaca-wait)

;;Turns off elpaca-use-package-mode current declartion
;;Note this will cause the declaration to be interpreted immediately (not deferred).
;;Useful for configuring built-in emacs features.
;;(use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
;;(elpaca nil (message "deferred"))

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
  :init
  (setq
   evil-want-integration t
   evil-want-keybinding nil
   evil-vsplit-window-right t
   evil-split-window-below t
   evil-want-C-u-scroll t
   evil-collection-setup-minibuffer t)
  (evil-mode))
(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-media '(dashboard dired ibuffer))
  (setq evil-normal-state-modes
        (append evil-emacs-state-modes
                evil-insert-state-modes
                evil-normal-state-modes
                evil-motion-state-modes))
  (evil-collection-init)
  (evil-set-undo-system 'undo-redo))

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
    "f S" '(save-buffer :wk "Save all files")
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

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;; Not working
;;(setq backup-directory-alist `(("." . "~/.config/emacs/backups")))

(setq backup-by-copying t)

(setq delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)

(use-package centered-window)

(use-package dashboard
  :ensure t
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
)

(use-package drag-stuff
  :init
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))

(setq visible-bell 1)
(set-message-beep 'silent)

(set-face-attribute 'default nil
  :font "IBM Plex Mono"
  :height 110
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "IBM Plex Mono"
  :height 120
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "IBM Plex Mono"
  :height 110
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "IBM Plex Mono"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package magit
  :commands magit-status)

(use-package diff-hl
  :hook ((magit-pre-refresh-hook . diff-hl-magit-pre-refresh)
         (magit-post-refresh-hook . diff-hl-magit-post-refresh))
  :init (global-diff-hl-mode))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(defun toggle-line-numbers ()
  (global-display-line-numbers-mode 1)
  (setq display-line-numbers-type 'relative))
(defun toggle-truncated-lines ()
  (global-visual-line-mode t))
(toggle-line-numbers)
(toggle-truncated-lines)

; Scroll by one line when moving off the screen by 1 line
  (setq scroll-conservatively 101)
  (defun update-scroll-margin (&optional frame)
	"Update scroll-margin based on the current window height."
	(interactive)
	(setq scroll-margin
	(ceiling (/ (float (window-height))
		  (* 3.5 1.2)))))

(add-hook 'window-size-change-functions #'update-scroll-margin)

(set-frame-parameter nil 'alpha-background 70)
(add-to-list 'default-frame-alist '(alpha-background . 90))

(add-hook 'after-make-frame-functions
  (lambda (frame)
      (with-selected-frame frame
         (update-scroll-keybinding)
         (load-selected-theme)
         (toggle-line-numbers)
         (toggle-truncated-lines))))

(use-package counsel
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
	 (XXX-mode . lsp)
	 ;; if you want which-key integration
	 (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
;; (use-package which-key
;;     :config
;;     (which-key-mode))

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

(electric-indent-mode -1)

(require 'org-tempo)

(use-package rainbow-mode
  :hook 
  ((org-mode prog-mode) . rainbow-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(indent-tabs-mode nil)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)     ;; Sets modeline height
  (doom-modeline-bar-width 5)   ;; Sets right bar width
  (doom-modeline-persp-name t)  ;; Adds perspective name to modeline
  (doom-modeline-persp-icon t)) ;; Adds folder icon next to persp name

(defun load-selected-theme ()
  (load-theme 'kanagawa t)
)

;; (use-package catppuccin-theme)

(use-package kanagawa-theme
  :config
  (load-selected-theme))

;; (add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")

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

(use-package yasnippet-snippets
  :hook (prog-mode . yas-minor-mode))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
;; Increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024)) ;; 1mb
