;;; -*- lexical-binding: t -*-

;; Envs
;; Formas de setar environments pro emacs, pretty good
; (when (eq system-type 'windows-nt)
;   ;; Add MSYS2 MinGW64 bin to the front of PATH
;   (setenv "PATH" (concat "C:\\Users\\Cliente\\scoop\\apps\\msys2\\2025-02-21\\mingw64\\bin;" (getenv "PATH")))
;   ;; Ensure Emacs uses this PATH for exec commands
;   (setq exec-path (append '("C:/Users/Cliente/scoop/apps/msys2/2025-02-21/mingw64/bin") exec-path)))

; (when (eq system-type 'windows-nt)
;   (setenv "PATH" (concat "C:\\Users\\Cliente\\scoop\\apps\\msys2\\2025-02-21\\usr\\bin;" (getenv "PATH")))
;   (setq exec-path (append '("C:/Users/Cliente/scoop/apps/msys2/2025-02-21/usr/bin") exec-path)))

;; Removes decoration from emacs
;; (push '(undecorated .t) default-frame-alist)
;; Disabled cuz it`s buggy with my WM (GlazeWm)

;; Install the Elpaca package manager
(defvar elpaca-installer-version 0.10)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; To avoid "too many open files" errors

(when (eq system-type 'windows-nt)
  (setq elpaca-queue-limit 12))

; (elpaca transient)
; (elpaca magit)

  ;; Install use-package support
  (elpaca elpaca-use-package
    ;; Enable use-package :ensure support for Elpaca.
    (elpaca-use-package-mode))

;; Customize stuff
  ;; Sets the customize file path
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  ;; Loads the customize file
  (load-file custom-file)


;; General functions
(defun my/log-message (message)
  "Log the MESSAGE to a log file."
  (let ((log-file (expand-file-name "emacs_server_log.txt" user-emacs-directory)))
    (write-region (format "[%s] %s\n" (current-time-string) message)
                  nil
                  log-file
                  'append)))

(defun toggle-line-numbers ()
  (interactive)
  (global-display-line-numbers-mode 1)
  (setq display-line-numbers-type 'relative))

(defun my/get-visual-selection ()
  "Return the text selected in visual mode as a plain string."
  (interactive)
  (when (use-region-p)
    (let ((beg (region-beginning))
          (end (region-end)))
      (message "Region selected: %d to %d" beg end)  ;; Log region bounds
      (let* ((selected-text (buffer-substring beg end))
             (clean-text (substring-no-properties selected-text)))
        (message "Selected text: '%s'" clean-text)
        clean-text))))

;; Turns off elpaca-use-package-mode current declaration
;; Note this will cause evaluate the declaration immediately. It is not deferred.
;; Useful for configuring built-in emacs features.
(use-package emacs
  :ensure nil
  :config

  (defun my/setup-startup ()
    "Configure startup-related settings."
    (setq inhibit-startup-message t
          inhibit-startup-echo-area-message user-login-name
          inhibit-default-init t
          initial-major-mode 'fundamental-mode
          initial-scratch-message nil))

  (defun my/setup-ui ()
    "Configure UI-related settings."
    (setq visible-bell 1
          ring-bell-function 'ignore
          use-dialog-box nil
          echo-keystrokes 0.5)
    (tool-bar-mode 0)
    (menu-bar-mode 0)
    (scroll-bar-mode 0)
    (column-number-mode 1)
    (show-paren-mode 1)
    (toggle-line-numbers))

  (defun my/setup-scrolling ()
    "Configure scrolling behavior."
    (setq scroll-conservatively 101
          scroll-margin 7
          mouse-wheel-progressive-speed nil
          mouse-wheel-scroll-amount '(3)
          auto-window-vscroll nil
          pixel-scroll-precision-interpolate-page t))

  (defun my/setup-editing ()
    "Configure editing settings."
    (setq-default select-active-regions nil
                  indent-tabs-mode nil
                  truncate-lines t
                  tab-width 2
                  tab-always-indent t)
    (setq truncate-partial-width-windows nil
          require-final-newline t
          create-lockfiles nil
          make-backup-files nil))

  (defun my/setup-file-management ()
    "Configure file and buffer management."
    (setq global-auto-revert-mode 1
          vc-follow-symlinks t
          confirm-kill-processes nil
          dired-dwim-target t))

  (defun my/setup-performance ()
    "Configure performance-related settings."
    (setq read-process-output-max (* 1024 1024)))

  (defun my/setup-treesitter ()
    "Configure Tree-sitter settings."
    (add-to-list 'treesit-extra-load-path (getenv "EMACS_TREESIT_PATH"))
    (setq global-treesit-auto-mode 1
          treesit-font-lock-level 4))

  (defun my/setup-search ()
    "Configure search and grep settings."
    (setq grep-command "rg --no-heading --color=never -n "
          grep-use-null-device nil))

  (defun my/setup-navigation ()
    "Configure navigation settings."
    (setq imenu-max-items 1000
          imenu-max-item-length 1000))

  (defun my/setup-debugging ()
    "Configure debugging settings."
    (setq gdb-many-windows t))

  (defun my/setup-platform-specific ()
    "Configure platform-specific settings."
    (when (eq system-type 'windows-nt)
      (set-message-beep 'silent)))

  ;; Initialize all configurations
  (my/setup-startup)
  (my/setup-ui)
  (my/setup-scrolling)
  (my/setup-editing)
  (my/setup-file-management)
  (my/setup-performance)
  (my/setup-treesitter)
  (my/setup-search)
  (my/setup-navigation)
  (my/setup-debugging)
  (my/setup-platform-specific)

  :hook ((elpaca-after-init . my/setup-fonts)))

;; Global variables
(defconst my/create-new-frame "create-new-frame"
  "Name of the trigger file used to create a new frame.")

;; Dotenv
;; TODO: didn't work??
; (use-package dot-env
;   :ensure t
;   :config
;   (dot-env-config))

;   (defun my/env (key)
;     "Retrieve the value of the environment variable by KEY.
;     If the value is nil, raise an error. KEY can be a string or a symbol."
;     (interactive "sEnter environment variable name: ")
;     (let* ((key-symbol (if (symbolp key) key (intern key))) ;; Convert string to symbol if necessary
;             (value (dot-env-get key-symbol)))  ;; Get the value using dot-env-get
;         (if value
;             value  ;; Return the value if it's not nil
;         (error "Error: Environment variable '%s' is not set." (symbol-name key-symbol)))))

;; Magit
;; (use-package my-magit-speedup-for-windows
;;   :load-path "~/.emacs.d/my-magit-speedup-for-windows"
;;   :init
;;   (require 'my-magit-process-cache)
;;   (require 'my-magit-speedup-settings))

;; (let ((repo-dir (expand-file-name "my-magit-speedup-for-windows" user-emacs-directory)))
;;   (add-to-list 'load-path repo-dir)
;;   (with-eval-after-load "magit"
;;     (require 'my-magit-process-cache)
;;     (require 'my-magit-speedup-settings)))

;; Evil mode
;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
  ;; Ensure that the 'evil' package is installed automatically if not present.
  :ensure t
  ;; Load 'evil' immediately instead of deferring it.
  :demand t
  ;; Sets pre-load configurations that must be set before Evil initializes.
  :init
  ;; These settings must be set before Evil loads, as they affect its initialization behavior.
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-vsplit-window-right t
        evil-split-window-below t
        evil-want-C-u-scroll t
        evil-collection-setup-minibuffer t)
  ;; This runs after Evil is fully loaded.
  :config
  ;; Enables Evil mode globally.
  (evil-mode 1))

  ;; TODO: testar
  (use-package evil-surround
    :ensure t
    :after evil
    :config (global-evil-surround-mode 1))

  (use-package evil-collection
    :ensure t  ;; Ensures 'evil-collection' is installed
    :after evil
    :config
    ; (setq evil-collection-media '(dashboard dired ibuffer))
    (setq evil-normal-state-modes
          (append evil-emacs-state-modes
                  evil-insert-state-modes
                  evil-normal-state-modes
                  evil-motion-state-modes))
    (evil-collection-init)
    (evil-set-undo-system 'undo-redo))

  (use-package evil-mc
    :ensure t
    :after evil
    :config
    (global-evil-mc-mode 1)
    :bind
    (:map evil-normal-state-map
          ("C-n"   . evil-mc-make-and-goto-next-match)
          ("C-p"   . evil-mc-make-and-goto-prev-match)
          ("C-M-n" . evil-mc-make-cursor-here)
          ("C-M-p" . evil-mc-undo-cursor)
          ("C-M-q" . evil-mc-undo-all-cursors)))

;; Company
(use-package company
  :ensure t
  :hook (elpaca-after-init . global-company-mode)
  :config

  (setq company-idle-delay 0
        company-minimum-prefix-length 2)

  (custom-set-faces
   '(company-tooltip ((t (:background "black" :foreground "#fff"))))
   '(company-tooltip-selection ((t (:background "#555" :foreground "#fff")))))

  :bind
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("C-o" . company-complete)))

;; Theme Configuration
(use-package autothemer
  :ensure t
  :init
  (my/add-theme-path)
  ;; :config
  ;; (my/load-theme)
  )

  ;; (defun my/load-theme ()
  ;;   "Load the Kanagawa theme."
  ;;   (interactive)
  ;;   (load-theme 'kanagawa t))

  (defun my/add-theme-path ()
    "Add the theme directory to `custom-theme-load-path`."
    (add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory)))

;; Treesitter
(use-package typescript-ts-mode
  :mode ("\\.ts\\'" . typescript-ts-mode)
  :ensure nil
  )

;; (defun setup-angular-lsp ()
;;   "Configure LSP for Angular with dynamic path adjustment."
;;   (setq lsp-clients-angular-language-server-command
;;         '("ngserver"
;;           "--ngProbeLocations" "./node_modules"
;;           "--tsProbeLocations" "./node_modules"
;;           "--stdio"))
;;   (defun start-angular-lsp ()
;;     (interactive)
;;     (let ((root (or (projectile-project-root) default-directory)))
;;       (setq lsp-clients-angular-language-server-command
;;             `("ngserver"
;;               "--ngProbeLocations" ,(concat root "node_modules")
;;               "--tsProbeLocations" ,(concat root "node_modules")
;;               "--stdio"))
;;       (lsp-deferred))))

;; Eglot configuration
(use-package eglot
  :ensure nil  ;; Built-in since Emacs 29
  :bind (:map eglot-mode-map
              ("C-c a" . eglot-code-actions)
              ("C-c d" . eldoc)
              ("C-c f" . eglot-format-buffer)
              ("C-c r" . eglot-rename))
  :hook ((rustic-mode . eglot-ensure)
         (zig-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (web-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '(rustic-mode . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs '(zig-mode . ("zls")))
  (add-to-list 'eglot-server-programs '((typescript-ts-mode js-mode web-mode) . ("typescript-language-server" "--stdio")))
  ;; Optional: Enable inlay hints for supported languages
  ;; (add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode)
  )

(use-package rust-mode
  :ensure t)

(use-package rustic
  :ensure t
  :after (rust-mode)
  :init (setq rustic-lsp-client 'eglot))

(use-package nix-mode
  :ensure t)

(use-package zig-mode
  :ensure t
  :mode (("\\.zig\\'" . zig-mode)
         ("\\.zon\\'" . zig-mode)))

(use-package markdown-ts-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-ts-mode)
  :config
  (add-to-list 'treesit-language-source-alist '(markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src"))
  (add-to-list 'treesit-language-source-alist '(markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src")))

(use-package web-mode
  :ensure t
  :mode "\\.html\\'")

;; (use-package tsx-mode
;;   ;; :straight '(tsx-mode :type git :host github :repo "orzechowskid/tsx-mode.el" :branch "emacs30")
;;   :defer t
;;   :mode "\\.ts\\'"
;;   :custom
;;   (tsx-mode-enable-css-in-js t))

(use-package typescript-ts-mode
  :ensure nil
  :mode (("\\.ts\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)))

(use-package tsx-ts-mode
  :mode ("\\.tsx\\'" . tsx-ts-mode)
  :ensure nil)

(use-package html-ts-mode
  :mode ("\\.html\\'" . html-ts-mode)
  :ensure nil)

;; Ensure projectile is available for project root detection
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1))

;; Vterm
(use-package vterm
  :ensure t)

(use-package toggle-term
  :ensure t
  :after vterm
  :config
  (setq toggle-term-size 35))
  ;; Maybe check this one out.
  ;; https://github.com/justinlime/toggle-term.el

(use-package catppuccin-theme
  :ensure t
  :config
  (my/load-theme))

  (defun my/load-theme ()
    "Load the Kanagawa theme."
    (interactive)
    (load-theme 'catppuccin t)
    (setq catppuccin-flavor 'mocha)
    (catppuccin-reload))

;; Centered window mode
(use-package centered-window
  :ensure t)

;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; (package-initialize)

;; IDO (Interactive Do)
(use-package ido-vertical-mode
  :ensure t
  :init
  (ido-vertical-mode 1)
  (setq ido-vertical-define-keys 'C-n-C-p-up-down-left-right))

  (use-package smex
    :ensure t
    :after ido-vertical-mode)

    (use-package ido-completing-read+
      :ensure t
      :after smex
      :config
      (ido-mode 1)
      (ido-everywhere 1)
      (ido-ubiquitous-mode 1))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  :hook ((elpaca-after-init . dashboard-insert-startupify-lists)
         (elpaca-after-init . dashboard-initialize)))

;; Restart emacs
(use-package restart-emacs
  :ensure t)

  (defun my/create-trigger-file-for-new-frame ()
    "Create the trigger file that will prompt Emacs to create a new frame."
    (interactive)
    (let ((client-trigger-file (expand-file-name my/create-new-frame user-emacs-directory)))
      (with-temp-file client-trigger-file
        (insert "start"))
      (message "Trigger file created: %s" client-trigger-file)))  ;; Optional: Log message for confirmation

  (defun my/restart-emacs ()
    "Create a trigger file for a new frame and restart Emacs, but only if the server is running."
    (interactive)
    (when (my/is-server-ready)
      (my/create-trigger-file-for-new-frame))
    (restart-emacs))

;; Persp
(use-package persp-mode
  :ensure t
  :init
  (setq persp-auto-save-fname "~/.emacs.d/persp-save")
  :config
  ;; TODO: criar keybinding pra isso
  ; (persp-mode 1)
)

;; Keybindings
(use-package general
  :after evil-collection
  :ensure t
  :config
  (general-evil-setup)
  (my/set-fonts-keys)
  (my/escape-prompt)
  (my/evil/basic-movements)
  (my/evil/ctrl)
  (my/evil/ctrl-and-shift)
  (my/evil/set-leader-key)
  (my/evil/leader/set-basic-key-bindings)
  (my/evil/leader/current-directory)
  (my/evil/leader/file-system)
  (my/evil/leader/evaluation)
  (my/evil/leader/help)
  (my/evil/leader/toggle)
  (my/evil/leader/window-buffer-management)
  (my/evil/leader/dired)
  (my/evil/leader/org-mode)
  (my/evil/leader/set-g-definer)
  (my/evil/leader/g)
  (my/evil/leader/set-semicollon-definer)
  (my/evil/leader/semicollon))

  (defun my/set-fonts-keys ()
    (global-set-key (kbd "C-=") 'text-scale-increase)
    (global-set-key (kbd "C--") 'text-scale-decrease)
    (global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
    (global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease))

  (defun my/escape-prompt ()
    "Makes Escape quit prompts (Minibuffer Escape)"
    (global-set-key [escape] 'keyboard-escape-quit))

  (defun my/evil/basic-movements ()
    "Sets the basic movements."
    (define-key evil-normal-state-map (kbd "H") 'beginning-of-line-text)
    (define-key evil-visual-state-map (kbd "H") 'beginning-of-line-text)
    (define-key evil-normal-state-map (kbd "L") 'end-of-line)
    (define-key evil-visual-state-map (kbd "L") 'end-of-line)
    (define-key evil-normal-state-map (kbd "K") 'evil-backward-paragraph)
    (define-key evil-visual-state-map (kbd "K") 'evil-backward-paragraph)
    (define-key evil-normal-state-map (kbd "J") 'evil-forward-paragraph)
    (define-key evil-visual-state-map (kbd "J") 'evil-forward-paragraph)
    (define-key evil-normal-state-map (kbd "C-u") (kbd (format "%dk" 15)))
    (define-key evil-visual-state-map (kbd "C-u") (kbd (format "%dk" 15)))
    (define-key evil-normal-state-map (kbd "C-d") (kbd (format "%dj" 15)))
    (define-key evil-visual-state-map (kbd "C-d") (kbd (format "%dj" 15)))
  )

  (defun my/evil/ctrl ()
    "Ctrl key bindings"
    (define-key evil-normal-state-map (kbd "C-t") 'toggle-term-vterm)
    ;; (define-key evil-insert-state-map (kbd "C-g") 'vterm-toggle)
  )

  (defun my/evil/ctrl-and-shift ()
    "Ctrl and Shift key bindings"
    (define-key evil-normal-state-map (kbd "C-S-p") (lambda () (interactive) (dired user-emacs-directory)))
  )

  (defun my/evil/set-leader-key ()
    "Sets the leader key"
    (general-create-definer dw/leader-keys
      :states '(normal insert visual emacs)
      :keymaps 'override
      :prefix  "SPC"
      :global-prefix "M-SPC"))

    (defun my/evil/leader/set-basic-key-bindings ()
      "Sets some basic keybindings"
      (dw/leader-keys
        "q" '(kill-this-buffer :wk "Quit")
        "Q" '(kill-this-buffer :wk "Quit")
        "ESC" '(keyboard-quit :wk "Close which-key")))

    (defun my/evil/leader/current-directory ()
      (dw/leader-keys
        "." '(:ignore t :wk "Current directory")
        ". y" '(copy-current-directory :wk "Copies the current directory")
        ; ". r" '(update-scroll-keybinding :wk "Sets the scrolling settings by window size")
      ))

      (defun copy-current-directory ()
        "Copy the current directory to the clipboard and print it in the minibuffer."
        (interactive)
        (kill-new default-directory)
        (message "Copied current directory: %s" default-directory))

    (defun my/evil/leader/file-system ()
      (dw/leader-keys
        "f" '(:ignore t :wk "Filesystem")
        ; Save
        "f s" '(save-buffer :wk "Save file")
        "f S" '(save-some-buffers :wk "Save all files")
        ; Find
        "f f" '(find-file :wk "Find file")
        "f t" '(grep :wk "Find text")
        "f T" '(find-grep-dired :wk "Find text in X folder")
        ; "f r" '(counsel-recentf :wk "Find recent files")
        "f c" '((lambda () (interactive) (find-file user-emacs-directory)) :wk "Edit emacs config")
        "f b" '(persp-mode 1 :wk "Load backup")))

    (defun my/evil/leader/evaluation ()
      (dw/leader-keys
        "e" '(:ignore t :wk "Evaluate")
        "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
        "e d" '(eval-defun :wk "Evaluate defun containing or after point")
        "e e" '(eval-expression :wk "Evaluate and elisp expression")
        "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
        "e r" '(eval-region :wk "Evaluate elisp in region")))

    (defun my/evil/leader/help ()
      (dw/leader-keys
        "h" '(:ignore t :wk "Help")
        ; Describe
        "h d" '(:ignore t :wk "Describe")
        "h d f" '(describe-function :wk "Function")
        "h d F" '(describe-face :wk "Face")
        "h d m" '(describe-mode :wk "Mode")
        "h d v" '(describe-variable :wk "Variable")
        "h d k" '(describe-key :wk "Key/Mouse")
        "h m" '(info :wk "Open manual")
        ; Apropos
        "h a" '(:ignore t :wk "Apropos")
        "h a a" '(apropos :wk "Apropos")
        "h a c" '(apropos-command :wk "Command")
        "h a l" '(apropos-library :wk "Library")
        "h a u" '(apropos-user-option :wk "User option")
        "h a v" '(apropos-value :wk "Value")
        ; Reload
        "h r" '(:ignore t :wk "Reload")
        "h r t" '(my/load-theme :wk "Theme" )
        "h r r" '(restart-emacs :wk "Emacs config")))

    (defun my/evil/leader/toggle ()
      (dw/leader-keys
        "t" '(:ignore t :wk "Toggle")
        "t l" '(toggle-line-numbers :wk "Toggle line numbers")
        "t t" '(visual-line-mode :wk "Toggle truncated lines")
        ; "t i" '(org-toggle-inline-images :wk "Toggle inline images")
        "t c" '(centered-window-mode :wk "Toggle the centered window mode")))

    (defun my/evil/leader/window-buffer-management ()
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
        "w L" '(buf-move-right :wk "Buffer move right")))

    (defun my/evil/leader/dired ()
      (dw/leader-keys
        "d" '(:ignore t :wk "Dired")
        "d d" '(dired :wk "Open dired")
        "d j" '(dired-jump :wk "Dired jump to current")
        ; "d n" '(neotree-dir :wk "Open directory in neotree")
        ; "d p" '(peep-dired :wk "Peep-dired")
      ))

    (defun my/evil/leader/org-mode ()
      (dw/leader-keys
        "o" '(:ignore t :wk "Org mode")
        "o l" '(:ignore t :wk "Link")
        "o l s" '(org-store-link :wk "Store link")
        "o l i" '(org-insert-link :wk "Insert link")))

    (defun my/evil/leader/set-g-definer ()
      (general-create-definer dw/g-keys
        :states '(normal insert visual emacs)
        :keymaps 'override
        :prefix  "g"
        :global-prefix "M-g"))

      (defun my/evil/leader/g ()
        (dw/g-keys "c" '(comment-line :wk "Comment")))

    (defun my/evil/leader/set-semicollon-definer ()
      (general-create-definer dw/semicollon-keys
        :states '(normal insert visual emacs)
        :keymaps 'override
        :prefix  ";"
        :global-prefix "M-;"))

      (defun my/evil/leader/semicollon ()
        (dw/semicollon-keys
          "q" '(kill-this-buffer :wk "Kill this buffer")
          ; "e" '(treemacs-select-window :wk "Selects treemacs")
          ; "E" '(treemacs :wk "Opens treemacs")
         ))

(use-package evil-visualstar
  :ensure t
  :after general
  :config
  (global-evil-visualstar-mode))

;; Whickey
(use-package which-key
  :ensure t
  :after general
  :config
  (setq which-key-idle-delay 0.1)
  (setq which-key-idle-secondary-delay 0.05)
  (setq which-key-show-remaining-keys t)
  (which-key-mode 1))

;; Fonts
(defun my/setup-fonts ()
  (interactive)
  "Setup all font configurations."
  (my/set-default-fonts)
  (my/set-italic-faces)
  ;; (setq-default line-spacing 0.4
  (run-at-time 0.1 nil 'my/apply-font-heights))

  (defun my/set-default-fonts ()
    "Configure default, variable-pitch, and fixed-pitch fonts."
    (add-to-list 'default-frame-alist '(font . "IBM Plex Mono"))
    (set-face-attribute 'default nil :font "IBM Plex Mono 10")
    (set-face-attribute 'variable-pitch nil :font "IBM Plex Mono" :height 100)
    (set-face-attribute 'fixed-pitch nil :font "IBM Plex Mono" :height 90))

  (defun my/set-italic-faces ()
    "Set italic style for comments and keywords."
    (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
    (set-face-attribute 'font-lock-keyword-face nil :slant 'italic))

  (defun my/apply-font-heights ()
    "Apply font height settings to all frames."
    (dolist (frame (frame-list))
      (set-face-attribute 'default frame :height 90)))

;; Reset GC threshold before loading GCMH
(setq gc-cons-threshold (* 16 1024 1024))  ; 16MB

;; Magic garbage collector hack
;; It's kinda small so maybe makes sense to just copy/paste
;; it into a config instead of installing it with straight
(use-package gcmh
  :ensure t
  :init
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 100 1024 1024))  ; 100mb
  :hook ((window-setup-hook . gcmh-mode)))

;; ; Server stuff
;;   (defun my/is-server-ready ()
;;     "Check if the Emacs server is fully initialized."
;;     (interactive)
;;     (eq (server-running-p) t))

;;   (defun my/check-for-trigger-file-and-delete ()
;;     "Check if the trigger file exists and delete it if it does."
;;     (let ((client-trigger-file (expand-file-name my/create-new-frame  user-emacs-directory)))
;;       (if (file-exists-p client-trigger-file)
;;           (progn
;;             (delete-file client-trigger-file)
;;             t)
;;         nil)))

  ;; (defun my/start-new-frame-if-trigger ()
  ;;   "Check for the trigger file and start a new Emacs frame if the file exists."
  ;;   (when (my/check-for-trigger-file-and-delete)
  ;;     (message "Starting a new Emacs frame due to restart trigger...")
  ;;     (start-process "emacsclient-new-frame"
  ;;                    nil
  ;;                    "cmd.exe"
  ;;                    "/c"
  ;;                    "emacsclientw"
  ;;                    "-c"
  ;;                    "-n")))

  ;; (defun my/wait-for-server-or-timeout-async (timeout callback)
  ;;   "Wait asynchronously for up to TIMEOUT seconds until the Emacs server has files in its directory.
  ;; If the server is ready within the timeout, CALL the CALLBACK function."
  ;;   (let ((server-dir (expand-file-name "server" user-emacs-directory))
  ;;         (elapsed 0))
  ;;     (cl-labels ((check-server ()
  ;;                   (if (directory-files server-dir t "^[^.].") ;; Ignore "." and ".."
  ;;                       (progn
  ;;                         (message "Emacs server is ready.")
  ;;                         (funcall callback)) ;; Call the callback when server is ready
  ;;                     (if (< elapsed timeout)
  ;;                         (progn
  ;;                           (setq elapsed (1+ elapsed))
  ;;                           (message "Waiting for Emacs server to be ready... (%ds)" elapsed)
  ;;                           (run-at-time 1 nil #'check-server)) ;; Schedule next check
  ;;                       (message "Timeout reached. Emacs server did not start."))))) ;; Timeout
  ;;       (check-server)))) ;; Start checking immediately

  ;; (defun my/start-new-frame-if-trigger ()
  ;;   "Check for the trigger file, wait asynchronously for the server, and start a new Emacs frame."
  ;;   (when (my/check-for-trigger-file-and-delete)
  ;;     (my/wait-for-server-or-timeout-async
  ;;      30
  ;;      (lambda ()
  ;;        (message "Starting a new Emacs frame due to restart trigger...")
  ;;        ;; (start-process "emacsclient-new-frame"
  ;;        ;;                nil
  ;;        ;;                "cmd.exe"
  ;;        ;;                "/c"
  ;;        ;;                "emacsclientw"
  ;;        ;;                "-c"
  ;;        ;;                "-n")
  ;;        (make-frame-command)
  ;;        ))))

  ;; ;; Call the function when Emacs starts
  ;; (add-hook 'elpaca-after-init-hook (lambda () (my/start-new-frame-if-trigger)))
