 ; start package.el with emacs
(require 'package)
; add MELPA to repository list
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
; initialize package.el
(package-initialize)

(require 'smart-hungry-delete)
(smart-hungry-delete-add-default-hooks)
(global-set-key (kbd "<backspace>") 'smart-hungry-delete-backward-char)
(global-set-key (kbd "C-d") 'smart-hungry-delete-forward-char)

(require 'dashboard)
(dashboard-setup-startup-hook)
(setq dashboard-items '((recents  . 5)
                        (bookmarks . 15)
                        (projects . 2)
                        (agenda . 0)
                        (registers . 2)))

(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
(add-to-list 'load-path "~/.emacs.d/custom")
(add-to-list 'load-path "~/.emacs.d/sunrise-commander")
(add-to-list 'load-path "~/.emacs.d/pde/lisp")

(require 'ztree)
(require 'sunrise-commander)
(require 'setup-general)
(if (version< emacs-version "24.4")
    (require 'setup-ivy-counsel)
  (require 'setup-helm))
;;(require 'setup-helm-gtags))
;; (require 'setup-ggtags)
(require 'setup-cedet)
(require 'xref)
(require 'setup-editing)

(pdf-tools-install)
;; irony mode
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

; start auto-complete with emacs
; (require 'auto-complete)
; do default config for auto-complete
; (require 'auto-complete-config)
; (ac-config-default)
; start yasnippet with emacs
(require 'yasnippet)
(yas-global-mode 1)

;;(require 'highlight-thing)
;;(global-highlight-thing-mode)

(load "pde-load")

(require 'switch-window)
(global-set-key (kbd "C-x o") 'switch-window)
(global-set-key (kbd "C-x 1") 'switch-window-then-maximize)
(global-set-key (kbd "C-x 2") 'switch-window-then-split-below)
(global-set-key (kbd "C-x 3") 'switch-window-then-split-right)
(global-set-key (kbd "C-x 0") 'switch-window-then-delete)

(global-set-key (kbd "C-x 4 d") 'switch-window-then-dired)
(global-set-key (kbd "C-x 4 f") 'switch-window-then-find-file)
(global-set-key (kbd "C-x 4 m") 'switch-window-then-compose-mail)
(global-set-key (kbd "C-x 4 r") 'switch-window-then-find-file-read-only)

(global-set-key (kbd "C-x 4 C-f") 'switch-window-then-find-file)
(global-set-key (kbd "C-x 4 C-o") 'switch-window-then-display-buffer)

(global-set-key (kbd "C-x 4 0") 'switch-window-then-kill-buffer)
; frame switching stuff
(global-set-key (kbd "C-x C-o") 'other-frame)
(global-set-key (kbd "M-ü") 'sunrise-cd)

(setq switch-window-shortcut-style 'qwerty)

; turn on Semantic
(semantic-mode 1)
; turn on ede mode
(global-ede-mode 1)
; create a project for our program.
(global-semantic-idle-scheduler-mode 1)

(defun linum-in-c-mode-hook ()
  (linum-mode 1))

(add-hook 'c-mode-hook 'linum-in-c-mode-hook)
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(setq electric-pair-mode t)

(fa-config-default)

;; function-args
(require 'function-args)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (tango-dark)))
 '(magit-log-arguments (quote ("-n256" "--graph" "--decorate" "--date-order")))
 '(package-selected-packages
   (quote
    (bitbake ztree vimish-fold wrap-region realgud treemacs-magit treemacs-icons-dired treemacs-projectile treemacs-evil treemacs smart-hungry-delete highlight-thing company company-c-headers company-irony-c-headers company-shell irony yasnippet switch-window ace-window dashboard pdf-tools zygospore zenburn-theme yasnippet-snippets yasnippet-classic-snippets ws-butler volatile-highlights visual-regexp-steroids use-package undo-tree smartscan smartparens neotree multiple-cursors magma-mode magit-stgit magit-p4 magit-org-todos magit-lfs magit-imerge magit-gitflow magit-gh-pulls magit-gerrit magit-find-file magit-filenotify magit-annex jump-char iy-go-to-char irony-eldoc iedit highlight-symbol heroku-theme helm-swoop helm-rtags helm-projectile helm-gtags helm-ag google-c-style function-args flymake-google-cpplint flymake-cursor flycheck-rtags flycheck-irony expand-region elpy dtrt-indent discover-my-major darkokai-theme darkmine-theme darkburn-theme company-rtags company-irony clean-aindent-mode clang-format badwolf-theme badger-theme auto-complete-clang-async auto-complete-clang auto-complete-c-headers auto-compile arjen-grey-theme anzu ample-zen-theme ace-jump-mode ac-rtags)))
 '(realgud-safe-mode nil))
(use-package smartparens-config
  :ensure smartparens
  :config
  (progn
    (show-smartparens-global-mode t)))

(defmacro def-pairs (pairs)
  `(progn
   ,@(cl-loop for (key . val) in pairs
           collect
           `(defun ,(read (concat
                           "wrap-with-"
                           (prin1-to-string key)
                           "s"))
                (&optional arg)
              (interactive "p")

            (sp-wrap-with-pair ,val)))))

(def-pairs ((paren . "(")
          (bracket . "[")
          (brace . "{")
          (single-quote . "'")
          (double-quote . "\"")
          (back-quote . "`")))

(setq winner-dont-bind-my-keys t)
(when (fboundp 'winner-mode)
  (winner-mode 1))

(defvar my-keys-minor-mode-map
(let ((map (make-sparse-keymap)))
  (define-key map (kbd "C-c (") 'wrap-with-parens)
  (define-key map (kbd "C-c [") 'wrap-with-brackets)
  (define-key map (kbd "C-c {") 'wrap-with-braces)
  (define-key map (kbd "C-M-f") 'sp-forward-sexp)
  (define-key map (kbd "C-M-k") 'sp-kill-sexp)
  (define-key map (kbd "C-M-b") 'sp-backward-sexp)
  (define-key map (kbd "C-M-n") 'sp-next-sexp)
  (define-key map (kbd "C-M-p") 'sp-previous-sexp)
  (define-key map (kbd "C-M-u") 'sp-up-sexp)
  (define-key map (kbd "C-M-d") 'sp-down-sexp)
  (define-key map "\C-x\C-m" 'helm-M-x)
  (define-key map "\C-c\C-m" 'helm-M-x)
  (define-key map "\C-x\C-k" 'kill-region)
  (define-key map [(meta m)] 'jump-char-forward)
  (define-key map [(shift meta m)] 'jump-char-backward)
  (define-key map (kbd "M-i") 'helm-swoop)
  (define-key map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)
  (define-key map (kbd "C-j") 'ace-jump-char-mode)
  (define-key map (kbd "C-ö") 'helm-imenu)
  (define-key map [f8] 'neotree-toggle)
  (define-key map (kbd "C-x g") 'magit-status)
  (define-key map (kbd "C-x M-g") 'magit-dispatch-popup)
  (define-key map (kbd "C-q") 'helm-buffers-list)
  (define-key map (kbd "C-M-j") 'next-buffer)
  (define-key map (kbd "C-M-l") 'previous-buffer)
  (define-key map (kbd "M-o") 'mode-line-other-buffer)
  (define-key map (kbd "C-c u") 'winner-undo)
  (define-key map (kbd "C-c r") 'winner-redo)
  map)
"my-keys-minor-mode keymap.")

(define-minor-mode my-keys-minor-mode
"A minor mode so that my key settings override annoying major modes."
:init-value t
:lighter " my-keys")

(my-keys-minor-mode 1)

(defun get-include-guard ()
  "Return a string suitable for use in a C/C++ include guard"
  (let* ((fname (buffer-file-name (current-buffer)))
         (fbasename (replace-regexp-in-string ".*/" "" fname))
         (inc-guard-base (replace-regexp-in-string "[.-]"
                                                   "_"
                                                   fbasename)))
    (concat (upcase inc-guard-base) "_")))

(add-hook 'find-file-not-found-hooks
          '(lambda ()
             (let ((file-name (buffer-file-name (current-buffer))))
               (when (string= ".h" (substring file-name -2))
                 (let ((include-guard (get-include-guard)))
                   (insert "/* ")
                   (newline)
                   (insert "  Author: Wadim Mueller ")
                   (newline)
                   (insert "  ")
                   (newline)
                   (insert "*/ ")
                   (newline)
                   (insert "#ifndef " include-guard)
                   (newline)
                   (insert "#define " include-guard)
                   (newline 4)
                   (insert "#endif")
                   (newline)
                   (previous-line 3)
                   (set-buffer-modified-p nil))))))

(global-set-key (kbd "M-o") 'mode-line-other-buffer)
; multiple cursors setup and key bindings
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C-<") 'mc/mark-next-like-this)
(global-set-key (kbd "C->") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(require 'jump-char)
(global-set-key (kbd "C-w") 'backward-kill-word)


;; ace-jump-mode config
(autoload
  'ace-jump-mode
  "ace-jump-mode"
  "Emacs quick move minor mode"
  t)
;; enable a more powerful jump back function from ace jump mode
(autoload
  'ace-jump-mode-pop-mark
  "ace-jump-mode"
  "Ace jump back:-)"
  t)
(eval-after-load "ace-jump-mode"
  '(ace-jump-mode-enable-mark-sync))

;; neotree config
(require 'neotree)
(setq projectile-switch-project-action 'neotree-projectile-action)

(setq projectile-switch-project-action 'helm-projectile)
;; (setq helm-projectile-fuzzy-match nil)
(require 'helm-projectile)
(helm-projectile-on)

;; ensure that we use only rtags checking
;; https://github.com/Andersbakken/rtags#optional-1
(defun setup-flycheck-rtags ()
  (interactive)
  (flycheck-select-checker 'rtags)
  ;; RTags creates more accurate overlays.
  (setq-local flycheck-highlighting-mode nil)
  (setq-local flycheck-check-syntax-automatically nil))

;; only run this if rtags is installed
(when (require 'rtags nil :noerror)
  ;; make sure you have company-mode installed
  (require 'company)
  (define-key c-mode-base-map (kbd "M-.")
    (function rtags-find-symbol-at-point))
  (define-key c-mode-base-map (kbd "M-,")
    (function rtags-find-references-at-point))
  ;; install standard rtags keybindings. Do M-. on the symbol below to
  ;; jump to definition and see the keybindings.
  (rtags-enable-standard-keybindings)
  ;; comment this out if you don't have or don't use helm
  (setq rtags-use-helm t)
  ;; company completion setup
  (setq rtags-autostart-diagnostics t)
  (rtags-diagnostics)
  (setq rtags-completions-enabled t)
  (push 'company-rtags company-backends)
  (global-company-mode)
  (define-key c-mode-base-map (kbd "<C-tab>") (function company-complete))
  ;; use rtags flycheck mode -- clang warnings shown inline
  (require 'flycheck-rtags)
  ;; c-mode-common-hook is also called by c++-mode
  (add-hook 'c-mode-common-hook #'setup-flycheck-rtags))
(bind-key "M-*" 'rtags-location-stack-back c-mode-base-map)
(global-company-mode)
(define-key c-mode-base-map (kbd "<C-tab>") (function company-complete))
(setq rtags-display-result-backend 'helm)
(add-hook 'c-mode-hook 'rtags-start-process-unless-running)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(magit-blame-date ((t nil)) t)
 '(term-color-blue ((t (:background "dark cyan" :foreground "dark cyan")))))
(put 'set-goal-column 'disabled nil)
(defun duplicate-line (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")

  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))

  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion

      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))

      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )

      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let

  ;; put the point in the lowest line and return
  (next-line arg))

(global-set-key (kbd "C-c d") 'duplicate-line)

(package-initialize)
;;(elpy-enable)
(yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)
(setq dired-dwim-target t)

;; dired settings
(setq dired-dwim-target t)
(setq dired-listing-switches "--group-directories-first -al")
(eval-after-load "dired" '(progn
                            (define-key dired-mode-map "F" 'find-name-dired)
                            (define-key dired-mode-map "a"
                              (lambda ()
                                (interactive)
                                (find-alternate-file "..")))
                            ))

(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

(package-install 'smartscan)
(add-hook 'prog-mode-hook 'smartscan-mode)

(defun find-grep-dired-do-search (dir regexp)
  "First perform `find-grep-dired', and wait for it to finish.
    Then, using the same REGEXP as provided to `find-grep-dired',
    perform `dired-do-search' on all files in the *Find* buffer."
  (interactive "DFind-grep (directory): \nsFind-grep (grep regexp): ")
  (find-grep-dired dir regexp)
  (while (get-buffer-process (get-buffer "*Find*"))
    (sit-for 1))
  (with-current-buffer "*Find*"
    (dired-toggle-marks)
    (dired-do-search regexp)))

(require 'expand-region)
(global-set-key (kbd "M-h") 'er/expand-region)

(require 'visual-regexp)
(require 'visual-regexp-steroids)
(define-key global-map (kbd "C-c q") 'vr/query-replace)
;; if you use multiple-cursors, this is for you:
(define-key global-map (kbd "C-c m") 'vr/mc-mark)

(add-hook 'dired-load-hook (function (lambda () (load "dired-x"))))


(defun sudo-find-file (file-name)
  "Like find file, but opens the file as root."
  (interactive "FSudo Find File: ")
  (let ((tramp-file-name (concat "/sudo::" (expand-file-name file-name))))
    (find-file tramp-file-name)))

(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name))
  (kill-new (file-truename buffer-file-name))
 )

(defun salvator-x-qemu ()
  "Run Qemu with Salvator-X Configuration."
  (interactive)
  (start-process-shell-command "QEMU-Salvator" "QEMU-Salvator-X" "/home/sefo/devel/github/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -machine salvator-x -kernel /home/sefo/devel/github/u-boot/u-boot")
  (switch-to-buffer "QEMU-Salvator-X")
  )

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(add-hook 'after-init-hook 'global-company-mode)
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))
(setq gdb-show-main t)

(wrap-region-mode t)

(require 'vimish-fold)

(require 'bb-mode)
(setq auto-mode-alist (cons '("\\.bb$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.inc$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bbappend$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bbclass$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.conf$" . bb-mode) auto-mode-alist))
