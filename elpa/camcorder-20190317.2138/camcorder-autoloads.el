;;; camcorder-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "camcorder" "camcorder.el" (0 0 0 0))
;;; Generated autoloads from camcorder.el

(let ((loads (get 'camcorder 'custom-loads))) (if (member '"camcorder" loads) nil (put 'camcorder 'custom-loads (cons '"camcorder" loads))))

(defconst camcorder-version "0.1" "\
Version of the camcorder package.")

(autoload 'camcorder-version "camcorder" "\
Version of the camcorder package." t nil)

(autoload 'camcorder-record "camcorder" "\
Open a new Emacs frame and start recording.
You can customize the size and properties of this frame with
`camcorder-frame-parameters'." t nil)

(autoload 'camcorder-start "camcorder" nil nil nil)

(defvar camcorder-mode nil "\
Non-nil if Camcorder mode is enabled.
See the `camcorder-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `camcorder-mode'.")

(custom-autoload 'camcorder-mode "camcorder" nil)

(autoload 'camcorder-mode "camcorder" "\
Toggle Camcorder mode on or off.

If called interactively, enable Camcorder mode if ARG is
positive, and disable it if ARG is zero or negative.  If called
from Lisp, also enable the mode if ARG is omitted or nil, and
toggle it if ARG is `toggle'; disable the mode otherwise.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\\{camcorder-mode-map}

\(fn &optional ARG)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; camcorder-autoloads.el ends here
