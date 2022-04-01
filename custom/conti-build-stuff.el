(require 'lshape-stuff)

(defun rtags-clear-cache()
  "Clear the rtags cache completely"
  (interactive)
  (async-shell-command "rm -r /home/local/.cache/rtags")
  )

(defun eclipse-start()
  "start ecliose"
  (interactive)
  (async-shell-command "cd /home/local/Downloads/eclipse && ./eclipse")
  )

(defun ngsm-on()
  "ngsm output on"
  (interactive)
  (async-shell-command "ngsm-on")
  )

(defun ngsm-off()
  "ngsm output off"
  (interactive)
  (async-shell-command "ngsm-off")
  )

(defun ngsm-reset()
  "ngsm output output off, wait 3 seconds and turn output on again"
  (interactive)
  (async-shell-command "ngsm-reset")
  )

(provide 'conti-build-stuff)
