(require 'lshape-stuff)


(defun ngsm-on()
  "ngsm output on"
  (interactive)
  (async-shell-command "ngsm-on")
  )


(defun caedge-ubuntu-net-boot-prepare()
  "deploy all artifacts on tftp and setup nfs"
  (interactive)
  (shell-command "cp -L /home/uia67865/mnt/ext_ssd/cadge/bsp38/build_hdk11-ubuntu/tmp/deploy/images/hdk11-ubuntu/Image /home/uia67865/devel/tftp")
  (shell-command "cp -L /home/uia67865/mnt/ext_ssd/cadge/bsp38/build_hdk11-ubuntu/tmp/deploy/images/hdk11-ubuntu/continental_hdk11.dtb /home/uia67865/devel/tftp")
  (shell-command "sudo systemctl stop nfs-kernel-server.service")
  (shell-command "sudo umount /home/uia67865/devel/nfs")
  (shell-command "sudo systemctl start nfs-kernel-server.service")
  (shell-command "sudo mount -o loop /home/uia67865/mnt/ext_ssd/cadge/bsp38/build_hdk11-ubuntu/tmp/deploy/images/hdk11-ubuntu/fsl-image-ubuntu-hdk11-ubuntu.ext4 /home/uia67865/devel/nfs")
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
