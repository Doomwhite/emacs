(use-package dap-mode
   :config
   (dap-auto-configure-mode)
   :bind 
   (("<f7>" . dap-step-in)
    ("<f8>" . dap-next)
    ("<f9>" . dap-continue)))
