;; -*- lexical-binding: t; -*-

;; Prevents package.el from automatically loading installed packages during startup.
(setq package-enable-at-startup nil)

;; Prevents package.el from modifying init.el by overriding the function package--ensure-init-file with ignore.
(advice-add #'package--ensure-init-file :override #'ignore)

;; This prevents Emacs from resizing frames automatically during startup.
(setq frame-inhibit-implied-resize t)
