(defun lshape-flash-monolith-w213-debug()
  "Flash the lshape traget with the scp flasher"
  (interactive)
  (async-shell-command "export SCP_FLASH_VARIANT=w213 && export SCP_FLASH_BUILD=DEBUG && cd /srv/scp-lshape-gc-flasher && ./flasher.py --flash_gc")
  )

(defun lshape-flash-monolith-w213-release()
  "Flash the lshape traget with the scp flasher"
  (interactive)
  (async-shell-command "export SCP_FLASH_VARIANT=w213 && cd /srv/scp-lshape-gc-flasher && ./flasher.py --flash_gc")
  )

(defun lshape-flash-monolith-tianma-debug()
  "Flash the lshape traget with the scp flasher"
  (interactive)
  (async-shell-command "cd /srv/scp-lshape-gc-flasher && export SCP_FLASH_BUILD=DEBUG && ./flasher.py --flash_gc")
  )

(defun lshape-flash-monolith-tianma-release()
  "Flash the lshape traget with the scp flasher"
  (interactive)
  (async-shell-command "cd /srv/scp-lshape-gc-flasher && ./flasher.py --flash_gc")
  )

(defun lshape-patch-for-bringup-ac()
  "Apply the path for running the gc without an ac and still see some output on the screen"
  (interactive)
  (async-shell-command "cd /srv/sw.sys.lshape_fdc_gc && patch -p1 < GC_ForceDisplay_patch.diff")
  )

(defun lshape-copy-initrd-to-destination()
  "Copy the yocto generated initial ramdist to initial loader folder"
  (interactive)
  (async-shell-command "cp /srv/il-lshape/workdir/tmp-distro-lshape-il/deploy/initial-loading/lshape/images/initrd-linux-kernel.cpio.gz.uimage /srv/sw.sys.lshape_fdc_gc/src/base/tool/il/adapt/ftp_media/lshape/images")
  )

(defun lshape-copy-uboot-to-destination()
  "Copy the lshape uboot to initial loader folder"
  (interactive)
  (async-shell-command "cp /srv/sw.sys.lshape_uboot/u-boot-elf.srec /srv/sw.sys.lshape_fdc_gc/src/base/tool/il/adapt/ftp_media/lshape/images/u-boot/u-boot-lshape.srec")
  )

(defun lshape-revert-patch-for-bringup-ac()
  "Remove the path for running the gc without an ac and still see some output on the screen"
  (interactive)
  (async-shell-command "cd /srv/sw.sys.lshape_fdc_gc && git checkout src/base/pkg/altia/lshape/viewif/adapt/generated/view_if_rte_interface.c && rm src/base/pkg/altia/lshape/viewif/adapt/generated/view_if_rte_interface.c.orig")
  )

(defun lshape-flash-monolith-with-resources()
  "Flash the lshape traget and resource iios with the scp flasher"
  (interactive)
  (async-shell-command "cd /srv/scp-lshape-gc-flasher && ./flasher.py --flash_gc_and_res")
  )

(defun lshape-flash-resouces-only()
  "Flash just the iio resources with the scp flasher"
  (interactive)
  (async-shell-command "cd /srv/scp-lshape-gc-flasher && ./flasher.py --flash_gc_resources")
  )

(defun lshape-flash-bootloader()
  "Flash the lshape bootloader with the scp flasher"
  (interactive)
  (async-shell-command "cd /srv/scp-lshape-gc-flasher && ./flasher.py --flash_gc_bl")
  )

(defun lshape-start-il-tianma()
  "Start Initial Loading for Tianma Target"
  (interactive)
  (async-shell-command "cd /srv/sw.sys.lshape_fdc_gc/bin_rsa-lshape-v1-tianma-deb && ./run_il.sh && stty -F /dev/ttyS0 ispeed 9600 && /bin/echo -e \"out 0\r\n\" > /dev/ttyS0 && sleep 4 && /bin/echo -e \"out 1\r\n\" > /dev/ttyS0")
  )

;(defun lshape-gc-run-mode-debugger-eth()
;  "Start the Integrity run mode debugging"
;  (interactive)
;  (async-shell-command "export GHS_LMHOST=@ls_bh_ghs_v6 && export GHS_LMWHICH=ghs && cd /srv/sw.sys.lshape_fdc_gc/bin_rsa-lshape-v1-tianma-deb && /opt/ghs/7.1.6_2018.1.4/_ide/multi -nosplash -I../src/base/pkg/bsp_rcar3/pkg/integrity/bin/ -Ibase/pkg/altia/lshape/ide/out/hex/ -Ibase/ide/out/hex -Iivfs_server -I../src/base/pkg/bsp_rcar3/pkg/gfx/bin -I/srv/sw.sys.lshape_fdc_gc/src/base/pkg/bsp_rcar3/pkg/int/libs/rcar_m3n/noipmmu -Ipvrserver -Immgr_server -Iusb_server -connect=\"mode=attach rtserv2 192.168.1.113\""))

(defun lshape-gc-run-mode-debugger-eth()
  "Start the Integrity run mode debugging"
  (interactive)
  (async-shell-command "cd /srv/sw.sys.lshape_fdc_gc/bin_rsa-lshape-v1-tianma-deb && printf '4\n' | ./menu.sh"))

(defun lshape-gc-run-mode-debugger-serial()
  "Start the Integrity run mode debugging"
  (interactive)
  (async-shell-command "export GHS_LMHOST=@ls_bh_ghs_v6 && export GHS_LMWHICH=ghs && cd /srv/sw.sys.lshape_fdc_gc/bin_rsa-lshape-v1-tianma-deb && /opt/ghs/7.1.6_2018.1.4/_ide/multi -nosplash -I../src/base/pkg/bsp_rcar3/pkg/integrity/bin/ -Ibase/pkg/altia/lshape/ide/out/hex/ -Ibase/ide/out/hex -Iivfs_server -I../src/base/pkg/bsp_rcar3/pkg/gfx/bin -I/srv/sw.sys.lshape_fdc_gc/src/base/pkg/bsp_rcar3/pkg/int/libs/rcar_m3n/noipmmu -Ipvrserver -Immgr_server -Iusb_server -connect=\"mode=attach rtserv2 -serial /dev/ttyUSB0 115200\""))


(defun lshape-open-gc-sdk()
  "Start Altia GCDK"
  (interactive)
  (async-shell-command "export GHS_LMHOST=@ls_bh_ghs_v6 && export GHS_LMWHICH=ghs && cd /home/local/devel/sandbox/ninja-parse-gc-sdk/multi && /usr/ghs/multi_716/mprojmgr default.gpj"))

(defun lshape-bsp-open-dired()
  "Open BSP in in dired"
  (interactive)
  (dired "/srv/sw.pkg.ghsint_rcar_gen3_gpr/pkg/int")
)

(defun lshape-app-open-dired()
  "Open Integrity Application in in dired"
  (interactive)
  (dired "/srv/sw.sys.lshape_fdc_gc")
  )

(defun lshape-reset-and-run-mode-attach()
  "Open Integrity Application in in dired"
  (interactive)
  (async-shell-command "/bin/echo -e \"out 0\r\n\" > /dev/ttyS0 && sleep 4 && /bin/echo -e \"out 1\r\n\" > /dev/ttyS0")
  (lshape-start-gc-run-mode-debugger)
  )

(defun lshape-show-resource-tree()
  "Show resource tree of lshape"
  (interactive)
  (find-file "/srv/sw.sys.lshape_fdc_gc/bin_renault-lshape-v1/base/tool/proseco/out/system.png")
  )

(defun lshape-copy-build-altia-to-target-destination()
  "copy the build altia into the target destination"
  (interactive)
  (async-shell-command "cp /srv/altia/mdl/libaltiaWinLib.a /srv/altia/mdl/libaltiaWinLib.dba /srv/altia/mdl/libaltiaAPIlibfloat.a /srv/altia/mdl/libaltiaAPIlibfloat.dba /srv/sw.sys.lshape_fdc_gc/src/base/pkg/altia/lshape/altia/l3l4/core")
  )

(defun lshape-ibl-debug-t32()
  "debug first stage ibl in trace32"
  (interactive)
  (async-shell-command "cd /srv/sw.sys.lshape_ibl/t32 && ~/t32/bin/pc_linux64/t32marm64 -c ~/t32/config_usb.t32")
  )

(defun lshape-open-bsp-in-multi()
  "open bsp project in multi ide"
  (interactive)
  (async-shell-command "export GHS_LMHOST=@ls_bh_ghs_v6 && export GHS_LMWHICH=ghs && /opt/ghs/7.1.6_2019.1.4/_ide/multi /srv/sw.pkg.ghsint_cmn_rcar3_gpr/int1178/platform-rcar3-devtree/default.gpj")
  )

(defun lshape-debug-initial-loading-t32()
  "debug the initial loading procedure using t32"
  (interactive)
  (async-shell-command "cd /srv/sw.sys.lshape_ibl/t32/il && ~/t32/bin/pc_linux64/t32marm64 -c ~/t32/config_usb.t32")
  )

(defun dlt-viewer-lsh()
  "start the dlt-viewer"
  (interactive)
  (async-shell-command "dlt-viewer ~/devel/dlt_configs/lshape.dlp")
  )


(provide 'lshape-stuff)
