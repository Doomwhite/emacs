;; Install the Elpaca package manager
(defvar elpaca-installer-version 0.8)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
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
(setq elpaca-queue-limit 12)

(elpaca transient)
(elpaca magit)

  ;; Install use-package support
  (elpaca elpaca-use-package
    ;; Enable use-package :ensure support for Elpaca.
    (elpaca-use-package-mode))

;; Customize stuff
  ;; Sets the customize file path
  (setq custom-file (expand-file-name ".emacs.custom.el" user-emacs-directory))
  ;; Loads the customize file
  (load-file custom-file)

;; Turns off elpaca-use-package-mode current declaration
;; Note this will cause evaluate the declaration immediately. It is not deferred.
;; Useful for configuring built-in emacs features.
(use-package emacs
  :ensure nil
  :config
  (setq ring-bell-function #'ignore)
  (tool-bar-mode 0)
  (menu-bar-mode 0)
  (scroll-bar-mode 0)
  (column-number-mode 1)
  (show-paren-mode 1))

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
