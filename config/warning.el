(defun my-suppress-comp-warnings (type format &rest args)
  "Suppress warnings of type `comp`."
  (unless (eq type 'comp)
    (apply #'message format args)))

(setq display-warning-function #'my-suppress-comp-warnings)
