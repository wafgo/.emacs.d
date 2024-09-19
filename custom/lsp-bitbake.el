(require 'lsp-mode)
(require 'cl-lib)
(require 'rx)
(require 'seq)
(require 'dom)
(require 'dash)
(require 's)

(defcustom bb-language-server-executable
  "language-server-bitbake"
  "Path of the language-server-bitbake executable."
  :type 'file
  )

(defcustom bbls-args
  "--stdio"
  "Additional command line options passed to the bitbake language server executable."
  :type '(repeat string)
  )

(add-to-list 'lsp-language-id-configuration '(bb-mode . "bitbake"))

(defun bbls--dosomethingstupidgRLF (_workspace params)
  "Put overlays on (preprocessed) inactive regions according to PARAMS."
  (warn "getRecipeLocalFiles: %S" params)
  ;; other logic here
)

(defun bbls--dosomethingstupidELD (_workspace params)
  "Put overlays on (preprocessed) inactive regions according to PARAMS."
  (warn " EmbeddedLanguageDocs ---> %S" params)
  ;; other logic here
)

  

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection '("/home/uia67865/mnt/ext_ssd/git/vscode-bitbake/server/out/ls-wrap.sh" "--stdio"))
  :major-modes '(bb-mode)
  :activation-fn (lsp-activate-on "bitbake")
  :request-handlers (ht ("bitbake/getRecipeLocalFiles" #'ignore))
  :notification-handlers
		  (lsp-ht ("bitbake/getRecipeLocalFiles" #'ignore)
		   	  ("bitbake/EmbeddedLanguageDocs" #'ignore))
  :server-id 'bitbake))

(provide 'lsp-bitbake)
