;;; gradle-mode-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from gradle-mode.el

(defvar gradle-mode nil "\
Non-nil if Gradle mode is enabled.
See the `gradle-mode' command
for a description of this minor mode.")
(custom-autoload 'gradle-mode "gradle-mode" nil)
(autoload 'gradle-mode "gradle-mode" "\
Emacs minor mode for integrating Gradle into compile.

Run gradle tasks from any buffer, scanning up to nearest gradle
directory to run tasks.

This is a global minor mode.  If called interactively, toggle the
`Gradle mode' mode.  If the prefix argument is positive, enable
the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `(default-value \\='gradle-mode)'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(register-definition-prefixes "gradle-mode" '("gradle-"))

;;; End of scraped data

(provide 'gradle-mode-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; gradle-mode-autoloads.el ends here
