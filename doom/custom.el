(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(magit-todos-insert-after '(bottom) nil nil "Changed by setter of obsolete option `magit-todos-insert-at'")
 '(safe-local-variable-values
   '((eval let
      ((project-directory
        (car
         (dir-locals-find-file default-directory))))
      (setq lsp-clients-typescript-server-args
       `("--tsserver-path" ,(concat project-directory ".yarn/sdks/typescript/bin/tsserver")
         "--stdio")))))
 '(warning-suppress-types '((lsp-mode) (defvaralias))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
