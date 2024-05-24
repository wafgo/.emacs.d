(defun chip_link_start()
  "start chip link tool"
  (interactive)
  (async-shell-command "/home/uia67865/devel/tools/chip_link/bin/chiplink")
  )

(defun t32_start_linux_s32()
  "start linux s32 t32 instance"
  (interactive)
  (async-shell-command "cd /home/uia67865/devel/git/linux-s32/trace32 && /home/uia67865/devel/tools/t32/bin/pc_linux64/t32marm64 -c /home/uia67865/devel/tools/t32/config_usb.t32")
  )

(defun t32_start_linux_mainline()
  "start linux s32 t32 instance"
  (interactive)
  (async-shell-command "cd /home/uia67865/mnt/ext_ssd/git/linux/trace32 && /home/uia67865/devel/tools/t32/bin/pc_linux64/t32marm64 -c /home/uia67865/devel/tools/t32/config_usb.t32")
  )

(defun t32_start_l4re()
  "start l4re trace32 instance"
  (interactive)
  (async-shell-command "cd /home/uia67865/mnt/ext_ssd/git/l4re/l4/t32 && /home/uia67865/devel/tools/t32/bin/pc_linux64/t32marm64 -c /home/uia67865/devel/tools/t32/config_usb.t32")
  )


(defun l4-build-and-deploy()
  "build and deploy l4"
  (interactive)
  (async-shell-command "cd /home/uia67865/mnt/ext_ssd/git/l4re/build-s32 && make && make E=uvmm-hdk11 uimage && cp -L bin/arm64_armv8a/bootstrap.uimage ~/devel/tftp/")
  )	

(defun caedge-copy-build-results-to-nfs()
  "copy flashimage and sdcard image to nfs"
  (interactive)
  (async-shell-command "cp /home/uia67865/devel/cadge/caedge-yocto-bsp-s32g/build_hdk11/tmp/deploy/images/hdk11/*.qspiflash /home/uia67865/devel/nfs/flash-images")
  (async-shell-command "cp /home/uia67865/devel/cadge/caedge-yocto-bsp-s32g/build_hdk11/tmp/deploy/images/hdk11/*.sdcard /home/uia67865/devel/nfs/flash-images")
  )

(defun remote_bdev_compile_and_copy()
  "copy the remote bdev module and copy it to nfs"
  (interactive)
  (shell-command "cp /home/uia67865/devel/git/linux-s32/drivers/block/pci-remote-disk.c /home/uia67865/devel/sandbox/remote_blockdev && pushd /home/uia67865/devel/sandbox/remote_blockdev && ./build.sh && popd")
  )

(defun hmp_reset()
  "hmp reset"
  (interactive)
  (shell-command "python /home/uia67865/devel/tools/hmp/hmp_set_output.py -s /dev/serial/by-id/usb-HAMEG_HAMEG_HO720-if00-port0 off && sleep 2 && python /home/uia67865/devel/tools/hmp/hmp_set_output.py -s /dev/serial/by-id/usb-HAMEG_HAMEG_HO720-if00-port0 on")
  )

(defun hmp_off()
  "hmp on"
  (interactive)
  (shell-command "python /home/uia67865/devel/tools/hmp/hmp_set_output.py -s /dev/serial/by-id/usb-HAMEG_HAMEG_HO720-if00-port0 off")
  )

(defun hmp_on()
  "hmp on"
  (interactive)
  (shell-command "python /home/uia67865/devel/tools/hmp/hmp_set_output.py -s /dev/serial/by-id/usb-HAMEG_HAMEG_HO720-if00-port0 on")
  )


(defun som-fastboot-kernel-flash()
  "flash the som lxc kernel"
  (interactive)
  (async-shell-command "python /home/uia67865/devel/git/fastboot_flash/fbf.py -s /dev/ttyUSB12 -r1 boot_a /home/uia67865/devel/cadge/som-lxc/snapdragon-auto-lxc-4-3-33-0_hlos_dev/apps/apps_proc/poky/build/tmp-glibc/deploy/images/lemanslxc-automotive/lemanslxc-boot.img")
  )


(provide 'caedge-stuff)
