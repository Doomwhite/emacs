(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)

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
