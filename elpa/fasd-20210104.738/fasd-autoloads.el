;;; fasd-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "fasd" "fasd.el" (0 0 0 0))
;;; Generated autoloads from fasd.el

(autoload 'fasd-find-file "fasd" "\
Use fasd to open a file, or a directory with dired.
If PREFIX is positive consider only directories.
If PREFIX is -1 consider only files.
If PREFIX is nil consider files and directories.
QUERY can be passed optionally to avoid the prompt.

\(fn PREFIX &optional QUERY)" t nil)

(autoload 'fasd-add-file-to-db "fasd" "\
Add current file or directory to the Fasd database." nil nil)

(defvar global-fasd-mode nil "\
Non-nil if Global Fasd mode is enabled.
See the `global-fasd-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `global-fasd-mode'.")

(custom-autoload 'global-fasd-mode "fasd" nil)

(autoload 'global-fasd-mode "fasd" "\
Toggle fasd mode globally.
   With no argument, this command toggles the mode.
   Non-null prefix argument turns on the mode.
   Null prefix argument turns off the mode.

If called interactively, enable Global Fasd mode if ARG is
positive, and disable it if ARG is zero or negative.  If called
from Lisp, also enable the mode if ARG is omitted or nil, and
toggle it if ARG is `toggle'; disable the mode otherwise.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\(fn &optional ARG)" t nil)

(register-definition-prefixes "fasd" '("fasd-"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; fasd-autoloads.el ends here
