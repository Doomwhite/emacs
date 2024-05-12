

(defvar zig-ts-mode-initialized nil
  "Flag to track initialization of zig-ts-mode.")

(defun my-zig-ts-mode-init ()
  "Initialize zig-ts-mode and LSP if not already initialized."
  (unless zig-ts-mode-initialized
    (setq zig-ts-mode-initialized t)
    (zig-ts-mode)
    (lsp))
  (when zig-ts-mode-initialized
    (lsp)))

  (use-package lsp-mode
    :init
    (setq lsp-keymap-prefix "C-c l")
    :hook ((zig-ts-mode . my-zig-ts-mode-init)
           (go-mode . lsp)
           (lsp-mode . lsp-enable-which-key-integration))
    :commands (lsp lsp-deferred)
    :config
    (add-to-list 'lsp-language-id-configuration '(zig-ts-mode . "zig")))

(use-package go-mode
  :mode ("\\.go\\'" . go-mode)
  :hook (go-mode . (lambda () 
  (setq treesit-font-lock-level 4)
  (setq tab-width 2)
  (setq indent-tabs-mode nil)
  ))
)

;; (use-package typescript-mode
;;   :mode "\\.ts\\'"
;;   :hook (typescript-mode . lsp-deferred)
;;   :hook (typescript-ts-mode . lsp-deferred)
;;   :config
;;   (setq typescript-indent-level 2))

;; (use-package python-mode
;;   :ensure t
;;   :hook (python-mode . lsp-deferred)
;;   :custom
;;   ;; NOTE: Set these if Python 3 is called "python3" on your system!
;;   ;; (python-shell-interpreter "python3")
;;   ;; (dap-python-executable "python3")
;;   (dap-python-debugger 'debugpy)
;;   :config
;;   (require 'dap-python))

(use-package zig-mode
  :ensure (zig-mode :host github :repo "nanzhong/zig-mode" :branch "tree-sitter")
  :mode (("\\.zig\\'" . zig-ts-mode)
         ("\\.zon\\'" . zig-ts-mode))
  :hook (zig-ts-mode . (lambda () (setq treesit-font-lock-level 4))))

;; (use-package zig-mode
;;    :hook (zig-mode . lsp-deferred)
;;    :mode "\\.zig\\'")

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)
  :commands dap-debug
  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup) ;; Automatically installs Node debug adapter if needed
  ;;:bind 
  ;;(("<f7>" . dap-step-in)
  ;; ("<f8>" . dap-next)
  ;; ("<f9>" . dap-continue))

  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
    :keymaps 'lsp-mode-map
    :prefix lsp-keymap-prefix
    "d" '(dap-hydra t :wk "debugger")))

  ;; (use-package dap-mode
  ;;    :config
  ;;    (dap-auto-configure-mode)
  ;;    :bind 
  ;;    (("<f7>" . dap-step-in)
  ;;     ("<f8>" . dap-next)
  ;;     ("<f9>" . dap-continue)))

(defun run-cmd-command (command)
  "Run a command using cmd.exe and display the output in a special-mode buffer."
  (interactive)
  (let* ((buffer-name "*cmd-output*")
         (cmd-command (format "/mnt/c/Windows/System32/cmd.exe /c \"%s\"" command)))
    (message "Running command: %s" cmd-command)
    ;; Delete buffer if it already exists
    (if (get-buffer buffer-name)
        (kill-buffer buffer-name))

    (with-current-buffer (get-buffer-create buffer-name)
      (erase-buffer)
      (insert (shell-command-to-string cmd-command))
      (goto-char (point-min))
      (special-mode)
      (pop-to-buffer buffer-name))))

(defun compile-handmade-project ()
  "Compile the Handmade Hero project and display the output in a special-mode buffer."
  (interactive)
  (let* ((project-root "C:/Users/Cliente/Documents/Projects/C/handmade/handmade")
         (misc-dir (concat project-root "/misc"))
         (code-dir (concat project-root "/code"))
         (command (format "cd %s && shell.bat && cd %s && build.bat" misc-dir code-dir)))
    (run-cmd-command command)))
