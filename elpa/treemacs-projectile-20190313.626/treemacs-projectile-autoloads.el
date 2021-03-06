;;; treemacs-projectile-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "treemacs-projectile" "treemacs-projectile.el"
;;;;;;  (23697 19208 817007 29000))
;;; Generated autoloads from treemacs-projectile.el

(autoload 'treemacs-add-and-display-current-project "treemacs-projectile" "\
Open treemacs and add the current projectile project to the workspace.
If the project is already registered with treemacs just move to its root.
Display an error if the current buffer is not part of any project.

\(fn)" t nil)

(autoload 'treemacs-projectile "treemacs-projectile" "\
Add one of `projectile-known-projects' to the treemacs workspace.
With a prefix ARG was for the name of the project instead of using the name of
the project's root directory.

\(fn &optional ARG)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; treemacs-projectile-autoloads.el ends here
