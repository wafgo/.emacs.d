(defun qemu_debug_ibl_in_qemu_full()
  "Start gdb client to debug IBL via qemu"
  (interactive)
  (qemu_start_waiting_for_gdb_client_connection)
  (gdb "/home/local/devel/cross/aarch64-gcc-7.4.1/bin/aarch64-linux-gnu-gdb --cd /home/local/devel/github-conti/qemu-lshape/build -x ../.gdb_setup -i=mi /srv/il/workdir/tmp-distro-lshape-il/work/aarch64-poky-linux/bootloader/1.0.0-r91/git/.temp/objects/boards/bl-lshape-rcar_m3n-integrity/1st.elf")
  )

(defun qemu_start_ibl_debug_client_only()
  "Start gdb client to debug IBL via qemu"
  (interactive)
  (gdb "gdb-multiarch --cd /home/local/devel/github-conti/qemu-lshape/build -i=mi -x ../.gdb_setup  /srv/il/workdir/tmp-distro-lshape-il/work/aarch64-poky-linux/bootloader/1.0.0-r91/git/.temp/objects/boards/bl-lshape-rcar_m3n-integrity/1st.elf")
  )

(defun qemu_start_waiting_for_gdb_client_connection()
  "Clear the rtags cache completely"
  (interactive)
  (async-shell-command "cd /home/local/devel/github-conti/qemu-lshape && build/qemu-system-aarch64 -M lshape -serial stdio -kernel /srv/il/workdir/tmp-distro-lshape-il/work/aarch64-poky-linux/bootloader/1.0.0-r91/git/.temp/objects/boards/bl-lshape-rcar_m3n-integrity/1st.elf -s -S")
  )

(defun qemu_start_qemu_in_gdb_wait()
  "Clear the rtags cache completely"
  (interactive)
  (gdb "gdb --cd /home/local/devel/github-conti/qemu-lshape/build -i=mi -x ../.qemu_gdb_setup --args ./qemu-system-aarch64 -M lshape -serial stdio -kernel /srv/il/workdir/tmp-distro-lshape-il/work/aarch64-poky-linux/bootloader/1.0.0-r91/git/.temp/objects/boards/bl-lshape-rcar_m3n-integrity/1st.elf -s -S")
  )

(defun qemu_start_qemu_in_gdb()
  "Clear the rtags cache completely"
  (interactive)
  (gdb "gdb --cd /home/local/devel/github-conti/qemu-lshape/build -i=mi -x ../.qemu_gdb_setup --args ./qemu-system-aarch64 -M lshape -nographic -kernel /srv/il/workdir/tmp-distro-lshape-il/work/aarch64-poky-linux/bootloader/1.0.0-r91/git/.temp/objects/boards/bl-lshape-rcar_m3n-integrity/1st.elf")
  )


(defun qemu_start_qemu_in_gdb_test_app()
  "Clear the rtags cache completely"
  (interactive)
  (gdb "gdb --cd /home/local/devel/github-conti/qemu-lshape/build -i=mi -x ../.qemu_gdb_setup --args ./qemu-system-aarch64 -M lshape -nographic -kernel /home/local/devel/github-conti/bare-metal-aarch64/test64.elf")
  )

(provide 'debugging-stuff)

