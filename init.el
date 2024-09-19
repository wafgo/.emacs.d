(add-to-list 'load-path "~/.emacs.d/custom")
;;(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Enable transient mark mode
(transient-mark-mode 1)


;;;;Org mode configuration
;; Enable Org mode
(require 'org)
(require 'dashboard)
(require 'cmake-mode)
(require 'ninja-mode)
(require 'e-byzanz)
;;(require 'ccls)
(require 'setup-helm)
(require 'projectile)
(require 'lsp-mode)
(require 'lsp-ui)
(require 'shell-pop)
(require 'hungry-delete)
(require 'jump-char)
(require 'multiple-cursors)
(require 'smartparens-config)
(require 'expand-region)
(require 'conti-build-stuff)
;; (require 'dap-mode)
;; (require 'dap-gdb-lldb)
;; (require 'debugging-stuff)
(require 'company)
;;(require 'company-lsp)
(require 'helm-projectile)
(require 'wc-mode)
(require 'bb-mode)
;;(require 'lsp-python-ms)
(require 'yasnippet)
;;(require 'sunrise)
(require 'company-auctex)
(require 'helm-fasd)
(require 'helm-ls-git)
(require 'helm-dictionary)
(require 'helm-descbinds)
(require 'helm-slime)
(require 'sublimity)
(require 'nerd-icons)
(require 'nerd-icons-dired)
(require 'caedge-stuff)
(require 'workgroups)
(require 'lsp-bitbake)
;; (require 'copilot)
;; (require 'eglot)
;; (add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
;; (add-hook 'c-mode-hook 'eglot-ensure)
;; (add-hook 'c++-mode-hook 'eglot-ensure)
;; (add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
;; (add-hook 'c-mode-hook 'eglot-ensure)
;; (add-hook 'c++-mode-hook 'eglot-ensure)
;;(require 'sublimity-scroll)
;;(require 'sublimity-map) ;; experimental
;;(require 'sublimity-attractive)
(sublimity-mode 1)
(workgroups-mode 1)
(setq sublimity-scroll-weight 10
      sublimity-scroll-drift-length 5)
(global-helm-slime-mode)
(helm-descbinds-mode)

(add-hook 'dired-mode-hook #'nerd-icons-dired-mode)
(ffap-bindings)
(use-package elpy
  :ensure t
  :init
  (elpy-enable))
(dolist (hook '(text-mode-hook latex-mode))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))

(add-hook 'prog-mode-hook
          (lambda ()
            (flyspell-prog-mode)
            ))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;;(lsp-treemacs-sync-mode 1)
(yas-global-mode 1)
;;(setq lsp-python-ms-auto-install-server t)
(setq dap-auto-configure-mode t)
(setq-default tab-with 4)


(setq gdb-many-windows t
      gdb-use-separate-io-buffer t)
(advice-add 'gdb-setup-windows :after
            (lambda () (set-window-dedicated-p (selected-window) t)))
(defconst gud-window-register 123456)

(defun gud-quit ()
  (interactive)
  (gud-basic-call "quit"))
 
(add-hook 'gud-mode-hook
          (lambda ()
            (gud-tooltip-mode)
            (window-configuration-to-register gud-window-register)
            (local-set-key (kbd "C-q") 'gud-quit)))
 
(advice-add 'gud-sentinel :after
            (lambda (proc msg)
              (when (memq (process-status proc) '(signal exit))
                (jump-to-register gud-window-register)
                (bury-buffer))))

;;(global-fasd-mode 1)
(setq auto-mode-alist (cons '("\\.bb$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.inc$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bbappend$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bbclass$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.conf$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.ned$" . lua-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.ts$" . js-mode) auto-mode-alist))

;;(setq ccls-executable "/home/uia67865/devel/git/ccls/Release/ccls")
(defun ccls/callee () (interactive) (lsp-ui-peek-find-custom "$ccls/call" '(:callee t)))
(defun ccls/caller () (interactive) (lsp-ui-peek-find-custom "$ccls/call"))
(defun ccls/vars (kind) (lsp-ui-peek-find-custom "$ccls/vars" `(:kind ,kind)))
(defun ccls/base (levels) (lsp-ui-peek-find-custom "$ccls/inheritance" `(:levels ,levels)))
(defun ccls/derived (levels) (lsp-ui-peek-find-custom "$ccls/inheritance" `(:levels ,levels :derived t)))
(defun ccls/member (kind) (interactive) (lsp-ui-peek-find-custom "$ccls/member" `(:kind ,kind)))

;; References w/ Role::Role
(defun ccls/references-read () (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
    (plist-put (lsp--text-document-position-params) :role 8)))

;; References w/ Role::Write
(defun ccls/references-write ()
  (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
   (plist-put (lsp--text-document-position-params) :role 16)))

;; References w/ Role::Dynamic bit (macro expansions)
(defun ccls/references-macro () (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
   (plist-put (lsp--text-document-position-params) :role 64)))

;; References w/o Role::Call bit (e.g. where functions are taken addresses)
(defun ccls/references-not-call () (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
   (plist-put (lsp--text-document-position-params) :excludeRole 32)))

(setq lsp-ui-doc-include-signature nil)  ; don't include type signature in the child frame
(setq lsp-ui-sideline-show-symbol nil)  ; don't show symbol on the right of info

;;(setq ccls-sem-highlight-method 'font-lock)
(setq ccls-sem-highlight-method 'overlay)

(dashboard-setup-startup-hook)
(setq dashboard-items '((recents  . 5)
                        (bookmarks . 15)
                        (projects . 2)
                        (agenda . 0)
                        (registers . 2)))
;; ; add MELPA to repository list
;; (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
;; ; initialize package.el
;; (package-initialize)
;; (unless (package-installed-p 'use-package)
;;   (package-install 'use-package))

(setq auto-mode-alist (cons '("\\.cmk$" . cmake-mode) auto-mode-alist))
;; (require 'use-package)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(bdf-directory-list
   '("/usr/local/share/emacs/fonts/bdf" "/usr/share/fonts/truetype/dejavu"))
 '(c-default-style
   '((c-mode . "cc-mode")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu")))
 '(chatgpt-shell-additional-curl-options '("-x" "http://127.0.0.1:3128"))
 '(chatgpt-shell-model-version 9)
 '(company-clang-executable "/usr/bin/clang")
 '(company-minimum-prefix-length 1)
 '(copilot-bin
   "/home/uia67865/mnt/ext_ssd/wizardcoder-python/wizardcoder-python-34b-v1.0.Q5_K_M.llamafile")
 '(custom-safe-themes
   '("f2c35f8562f6a1e5b3f4c543d5ff8f24100fae1da29aeb1864bbc17758f52b70" default))
 '(elpy-rpc-virtualenv-path 'default)
 '(helm-completion-style 'emacs)
 '(helm-rg-default-directory 'git-root)
 '(langtool-default-language 'auto)
 '(lsp-clangd-binary-path "/usr/bin/clangd")
 '(lsp-enable-file-watchers nil)
 '(lsp-enable-indentation t)
 '(lsp-headerline-breadcrumb-enable t)
 '(lsp-idle-delay 0.0)
 '(lsp-imenu-index-function 'lsp-imenu-create-categorized-index)
 '(lsp-lens-enable t)
 '(lsp-log-io t)
 '(lsp-pyls-plugins-flake8-enabled t)
 '(lsp-pyls-plugins-jedi-completion-fuzzy t)
 '(lsp-semantic-tokens-enable t)
 '(lsp-semantic-tokens-warn-on-missing-face nil)
 '(lsp-ui-doc-header t)
 '(lsp-ui-doc-include-signature t)
 '(lsp-ui-doc-show-with-cursor t)
 '(lsp-ui-sideline-actions-icon nil)
 '(lsp-ui-sideline-diagnostic-max-line-length 100)
 '(lsp-ui-sideline-ignore-duplicate nil)
 '(lsp-ui-sideline-show-code-actions nil)
 '(lsp-ui-sideline-show-hover nil)
 '(lsp-ui-sideline-show-symbol nil)
 '(package-selected-packages
   '(nerd-icons-dired nerd-icons powershell robot-mode jenkinsfile-mode yaml-mode soong-mode kotlin-mode gradle-mode rustic org-arbeitszeit message-view-patch mu4e-alert go-mode lua-mode protobuf-mode fasd clang-format dockerfile-mode sublimity helm-slime helm-descbinds helm-dictionary helm-ls-git evil-tutor helm-c-yasnippet helm-system-packages elpy company-auctex lsp-treemacs yasnippet-snippets lsp-python-ms meson-mode helm-lsp helm-z evil ccls google-this camcorder command-log-mode minimap posframe dts-mode bison-mode bitbake ninja-mode multi-vterm vterm-toggle vtm yasnippet-classic-snippets vterm smartscan expand-region vlf smartparens pdf-tools beacon zenburn-theme ace-jump-mode jump-char helm-swoop swoop multiple-cursors hungry-delete shell-pop flycheck helm-dash cmake-mode dashboard helm-projectile projectile magit helm-rg helm))
 '(projectile-globally-ignored-directories
   '(".idea" ".vscode" ".ensime_cache" ".eunit" ".git" ".hg" ".fslckout" "_FOSSIL_" ".bzr" "_darcs" ".tox" ".svn" ".stack-work" ".ccls-cache" ".clangd"))
 '(projectile-indexing-method 'alien)
 '(shell-pop-term-shell "/bin/bash")
 '(sublimity-mode t)
 '(vterm-shell "/bin/bash")
 '(warning-suppress-types '((comp) (comp) (comp) (comp) (comp)))
 '(winner-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#3F3F3F" :foreground "#DCDCCC" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 128 :width normal :family "FiraCodeNerdFontMono "))))
 '(lsp-face-semhl-comment ((t (:inherit font-lock-comment-face))))
 '(lsp-face-semhl-definition ((t (:inherit font-lock-function-name-face :weight bold))))
 '(lsp-ui-sideline-current-symbol ((t (:foreground "white" :box (:line-width (1 . -1) :color "white") :weight ultra-bold :height 0.99)))))
(setq projectile-switch-project-action 'helm-projectile)
(helm-projectile-on)

(add-hook 'after-init-hook 'global-company-mode)
;;(define-key c-mode-base-map (kbd "<C-tab>") (function company-complete))

(global-set-key (kbd "C-w") 'backward-kill-word)
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(setq dired-dwim-target t)
(setq dired-listing-switches "--group-directories-first -al")
(eval-after-load "dired" '(progn
                            (define-key dired-mode-map "F" 'find-name-dired)
                            (define-key dired-mode-map "a"
                              (lambda ()
                                (interactive)
                                (find-alternate-file "..")))
                            ))

(define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)
(global-set-key (kbd "C-=") 'er/expand-region)

(add-hook 'prog-mode-hook 'smartscan-mode)

(defalias 'yes-or-no-p 'y-or-n-p)
(use-package projectile
  :init
  (projectile-global-mode)
  (setq projectile-enable-caching t))

(use-package vterm
  :ensure t)

(use-package multi-vterm :ensure t)
(global-set-key (kbd "C-ü") 'vterm-toggle-cd)
(setq vterm-toggle-fullscreen-p nil)
;Switch to next vterm buffer
(define-key vterm-mode-map (kbd "s-n")   'vterm-toggle-forward)
;Switch to previous vterm buffer
(define-key vterm-mode-map (kbd "s-p")   'vterm-toggle-backward)
(add-to-list 'display-buffer-alist
             '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
                (display-buffer-reuse-window display-buffer-at-bottom)
                ;;(display-buffer-reuse-window display-buffer-in-direction)
                ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                ;;(direction . bottom)
                ;;(dedicated . t) ;dedicated is supported in emacs27
                (reusable-frames . visible)
                (window-height . 0.3)))

(defun sudo-find-file (file-name)
  "Like find file, but opens the file as root."
  (interactive "FSudo Find File: ")
  (let ((tramp-file-name (concat "/sudo::" (expand-file-name file-name))))
    (find-file tramp-file-name)))

;; activate whitespace-mode to view all whitespace characters
(global-set-key (kbd "C-c w") 'whitespace-mode)
(windmove-default-keybindings)

(beacon-mode 1)

(define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
(define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
(define-key lsp-ui-mode-map (kbd "C-x C-p") 'lsp-ui-find-prev-reference)
(define-key lsp-ui-mode-map (kbd "C-x C-n") 'lsp-ui-find-next-reference)
(define-key lsp-ui-mode-map (kbd "C-M-i") 'lsp-ui-imenu)
(define-key lsp-ui-mode-map (kbd "C-.") 'helm-lsp-workspace-symbol)

(add-hook 'lsp-mode-hook 'lsp-ui-mode)

(add-hook 'c-mode-common-hook #'lsp)
(add-hook 'rust-mode-hook #'lsp)
(add-hook 'bb-mode-hook #'lsp)
(add-hook 'js-mode-hook #'lsp)
;;(add-hook 'python-mode-hook #'lsp)
;;(add-hook 'sh-mode-hook #'lsp)
(add-hook 'cmake-mode-hook #'lsp)
(add-hook 'cmake-mode-hook #'smartparens-mode)
(add-hook 'prog-mode-hook #'smartparens-mode)
(pdf-tools-install)
(global-hungry-delete-mode)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C-<") 'mc/mark-next-like-this)
(global-set-key (kbd "C->") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(define-key global-map (kbd "C-j") 'ace-jump-mode)

(defvar wmu-keys-minor-mode-map
(let ((map (make-sparse-keymap)))
  (define-key map "\C-x\C-m" 'helm-M-x)
  (define-key map "\C-c\C-m" 'helm-M-x)
  (define-key map "\C-x\C-k" 'kill-region)
  (define-key map (kbd "M-i") 'helm-swoop)
  (define-key map (kbd "C-x g") 'magit-status)
  (define-key map (kbd "C-x M-g") 'magit-dispatch-popup)
  (define-key map (kbd "C-ö") 'helm-mini)
  (define-key map (kbd "C-M-ö") 'helm-projectile-switch-to-buffer)
  (define-key map (kbd "C-M-ä") 'helm-rg)
  (define-key map (kbd "C-c C-k") 'term-char-mode)
  (define-key map (kbd "M-ä") 'helm-projectile-rg)
  (define-key map (kbd "M-ö") 'projectile-find-file)
  (define-key map (kbd "C-M-j") 'next-buffer)
  (define-key map (kbd "C-M-l") 'previous-buffer)
  (define-key map (kbd "M-o") 'mode-line-other-buffer)
  (define-key map (kbd "C-x b") 'helm-bookmarks)
  (define-key map (kbd "M-q") 'helm-fasd)
  (define-key map (kbd "C-c C-j") 'yas-insert-snippet)
  (define-key map (kbd "C-x C-d") 'helm-browse-project)
  (define-key map (kbd "C-x r p") 'helm-projects-history)
  (define-key map (kbd "C-o") 'other-window)
  map)
"wmu-keys-minor-mode keymap.")

(define-minor-mode wmu-keys-minor-mode
"A minor mode so that my key settings override annoying major modes."
:init-value t
:lighter " wmu-keys")


(wmu-keys-minor-mode 1)
(load-theme 'zenburn t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq compilation-scroll-output 'first-error)
(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; remap C-a to `smarter-move-beginning-of-line'
(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)

(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))
(setq history-delete-duplicates t)
(add-to-list 'display-buffer-alist (cons "\\*Async Shell Command\\*.*" (cons #'display-buffer-no-window nil)))

(defun lsp-action-retrieve-and-run ()
  "Retrieve, select, and run code action."
  (interactive)
  (lsp--cur-workspace-check)
  (lsp--send-request-async (lsp--make-request
                            "textDocument/codeAction"
                            (lsp--text-document-code-action-params))
                           (lambda (actions)
                             (setq lsp-code-actions actions)
                             (condition-case nil
                                 (call-interactively 'lsp-execute-code-action)
                               (quit "Quit")))))

(setq shell-file-name "/bin/bash")
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(company-auctex-init)




(defun fd-switch-dictionary()
  (interactive)
  (let* ((dic ispell-current-dictionary)
    	 (change (if (string= dic "deutsch8") "english" "deutsch8")))
    (ispell-change-dictionary change)
    (message "Dictionary switched from %s to %s" dic change)
    ))

;; Clang stuff
(require 'clang-format)
(setq clang-format-style "file")

(setq auto-revert-buffer-list-filter
      'magit-auto-revert-repository-buffer-p)

(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))
(add-hook 'mail-mode-hook 'turn-on-auto-fill)
  ;; Yes, you can do this same trick with the cool "It's All Text" firefox add-on :-)
  (add-to-list 'auto-mode-alist '("/mutt-\\|itsalltext.*mail\\.google" . mail-mode))
  (add-hook 'mail-mode-hook 'turn-on-auto-fill)
  (add-hook
   'mail-mode-hook
   (lambda ()
     (define-key mail-mode-map [(control c) (control c)]
       (lambda ()
         (interactive)
         (save-buffer)
         (server-edit)))))

  (add-to-list 'auto-mode-alist '(".*mutt.*" . message-mode))                                                                   
  (setq mail-header-separator "")                                                                                               
  (add-hook 'message-mode-hook
          'turn-on-auto-fill
          (function
           (lambda ()
             (progn
               (local-unset-key "\C-c\C-c")
               (define-key message-mode-map "\C-c\C-c" '(lambda ()
                                                          "save and exit quickly"
                                                          (interactive)
                                                          (save-buffer)
                                                          (server-edit)))))))


(add-to-list 'load-path "~/mnt/ext_ssd/git/mu/build/mu4e")
(require 'mu4e)

;;default
(setq mu4e-maildir (expand-file-name "~/mnt/ext_ssd/Mail/gmail"))

(setq mu4e-drafts-folder "/[Gmail].Drafts")
(setq mu4e-sent-folder   "/[Gmail].Gesendet")
(setq mu4e-trash-folder  "/[Gmail].Papierkorb")

;; don't save message to Sent Messages, GMail/IMAP will take care of this
(setq mu4e-sent-messages-behavior 'delete)

;; setup some handy shortcuts
(setq mu4e-maildir-shortcuts
      '(("/INBOX"             . ?i)
        ("/[Gmail].Gesendet" . ?s)
        ("/[Gmail].Papierkorb"     . ?t)))


(setq mu4e-html2text-command "w3m -T text/html" ; how to hanfle html-formatted emails
      mu4e-update-interval 300                  ; seconds between each mail retrieval
      mu4e-headers-auto-update t                ; avoid to type `g' to update
      mu4e-view-show-images t                   ; show images in the view buffer
      mu4e-compose-signature-auto-include nil   ; I don't want a message signature
      mu4e-use-fancy-chars t)  
;; allow for updating mail using 'U' in the main view:
(setq mu4e-get-mail-command "offlineimap")

;; something about ourselves
;; I don't use a signature...
(setq
 user-mail-address "wafgo01@gmail.com"
 user-full-name  "Wadim Mueller"
 ;; message-signature
 ;;  (concat
 ;;    "Foo X. Bar\n"
 ;;    "http://www.example.com\n")
)
(setq mu4e-compose-reply-ignore-address '("no-?reply" "wafgo01@gmail.com"))
;; sending mail -- replace USERNAME with your gmail username
;; also, make sure the gnutls command line utils are installed
;; package 'gnutls-bin' in Debian/Ubuntu, 'gnutls' in Archlinux.
(require 'smtpmail)

(require 'smtpmail)
(setq message-send-mail-function 'smtpmail-send-it
   starttls-use-gnutls t
   smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
   smtpmail-auth-credentials
      (expand-file-name "~/.authinfo.gpg")
   smtpmail-default-smtp-server "smtp.gmail.com"
   smtpmail-smtp-server "smtp.gmail.com"
   smtpmail-smtp-service 587)

;; alternatively, for emacs-24 you can use:
;;(setq message-send-mail-function 'smtpmail-send-it
;;     smtpmail-stream-type 'starttls
;;     smtpmail-default-smtp-server "smtp.gmail.com"
;;     smtpmail-smtp-server "smtp.gmail.com"
;;     smtpmail-smtp-service 587)

;; don't keep message buffers around
(setq message-kill-buffer-on-exit t)

;; Choose the style you prefer for desktop notifications
;; If you are on Linux you can use
;; 1. notifications - Emacs lisp implementation of the Desktop Notifications API
;; 2. libnotify     - Notifications using the `notify-send' program, requires `notify-send' to be in PATH
;;
;; On Mac OSX you can set style to
;; 1. notifier      - Notifications using the `terminal-notifier' program, requires `terminal-notifier' to be in PATH
;; 1. growl         - Notifications using the `growl' program, requires `growlnotify' to be in PATH
(mu4e-alert-set-default-style 'libnotify)
(add-hook 'after-init-hook #'mu4e-alert-enable-notifications)
(add-hook 'after-init-hook #'mu4e-alert-enable-mode-line-display)
(add-hook 'gnus-part-display-hook 'message-view-patch-highlight)

(setq remote-file-name-inhibit-cache nil)
(setq vc-ignore-dir-regexp
      (format "%s\\|%s"
                    vc-ignore-dir-regexp
                    tramp-file-name-regexp))
(setq tramp-verbose 1)

;; (setq url-proxy-services
;;       '(("http" . "http://127.0.0.1:3128")
;;         ("https" . "https://127.0.0.1:3128")))
