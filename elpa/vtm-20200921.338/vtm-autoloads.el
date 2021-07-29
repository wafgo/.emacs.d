;;; vtm-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


(defvar vtm-edit-mode nil "\
Non-nil if Vtm-Edit mode is enabled.
See the `vtm-edit-mode' command
for a description of this minor mode.")

(custom-autoload 'vtm-edit-mode "vtm" nil)

(autoload 'vtm-edit-mode "vtm" "\
Enable editing the vtm file.

If called interactively, enable Vtm-Edit mode if ARG is positive,
and disable it if ARG is zero or negative.  If called from Lisp,
also enable the mode if ARG is omitted or nil, and toggle it if
ARG is `toggle'; disable the mode otherwise.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\(fn &optional ARG)" t nil)

(autoload 'vtm-mode "vtm" "\
Elisp Mode starter for vtm files.

\(fn)" t nil)

(register-definition-prefixes "vtm" '("vtm-"))

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; vtm-autoloads.el ends here
