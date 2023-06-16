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

(defun t32_start()
  "Start T32"
  (interactive)
  (async-shell-command "~/devel/tools/trace32/2021_09/bin/pc_linux64/t32marm64 -c ~/devel/tools/trace32/2021_09/config_usb.t32")
  )


(defun scp_kernel_dtb_to_s32g_target()
  "Start T32"
  (interactive)
  (async-shell-command "/home/uia67865/devel/cadge/sandbox/scp_to_target.sh")
  )

(provide 'conti-build-stuff)
