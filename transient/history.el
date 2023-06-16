((magit-blame
  ("-w"))
 (magit-branch nil)
 (magit-commit nil
	       ("--signoff"))
 (magit-diff
  ("--no-ext-diff" "--stat"))
 (magit-dispatch nil)
 (magit-gitignore nil)
 (magit-log
  ("-n256" "--graph" "--decorate")
  ("-n256" "--author=Wadim Mueller <wadim.mueller@continental-corporation.com>" "--graph" "--decorate")
  nil
  ("-n256" "--author=Cristian02 Lupu <cristian.2.lupu@continental-corporation.com>" "--graph" "--decorate")
  ("-n256"
   ("--" "src/base/tool/il/adapt/ftp_media/lshape/images/bl-lshape-rcar_m3n-integrity.iio")
   "--graph" "--decorate")
  (("--" "src/base/pkg/lifecycle/lc-rstp-sync/src/lc-rstp-sync.cpp")
   "--follow" "--date-order")
  ("-n256"
   ("--" "src/base/pkg/lifecycle/lc-rstp-sync/src/lc-rstp-sync.cpp")
   "--follow" "--graph" "--decorate")
  ("-n256"
   ("--" "src/base/pkg/lifecycle/lc-rstp-sync/src/lc-rstp-sync.cpp")
   "--graph" "--decorate")
  ("-n256"
   ("--" "src/base/pkg/reincarnate/cfg/reinarnate.sdh")
   "--graph" "--decorate")
  ("-n256"
   ("--" "src/base/pkg/ospm/CMakeLists.txt")
   "--graph" "--decorate"))
 (magit-log:-G "qqqq")
 (magit-merge nil)
 (magit-patch nil)
 (magit-patch-create nil)
 (magit-push nil)
 (magit-revert
  ("--edit"))
 (magit-stash nil
	      ("--all")
	      ("--include-untracked"))
 (magit:-- "src/base/tool/il/adapt/ftp_media/lshape/images/bl-lshape-rcar_m3n-integrity.iio" "" "src/base/pkg/lifecycle/lc-rstp-sync/src/lc-rstp-sync.cpp" "src/base/pkg/reincarnate/cfg/reinarnate.sdh" "src/base/pkg/ospm/CMakeLists.txt" "scripts/build.py,")
 (magit:--author "Wadim Mueller <wadim.mueller@continental-corporation.com>" "Cristian02 Lupu <cristian.2.lupu@continental-corporation.com>"))
