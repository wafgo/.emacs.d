((magit-blame
  ("-w"))
 (magit-branch nil)
 (magit-commit nil
	       ("--signoff")
	       ("--all"))
 (magit-diff
  ("--no-ext-diff" "--stat"))
 (magit-dispatch nil)
 (magit-fetch nil)
 (magit-gitignore nil)
 (magit-log
  ("-n256" "--author=Wadim Mueller <wafgo01@gmail.com>" "--graph" "--decorate")
  ("-n256"
   ("--" "configs/am64x_evm_a53_defconfig")
   "--graph" "--decorate")
  ("-n256" "--author=Sergej Lopatin <Sergej.Lopatin@continental-corporation.com>" "--graph" "--decorate")
  ("-n256" "--graph" "--decorate")
  ("-n256" "--date-order" "--graph" "--decorate")
  ("-n256" "--author=Wadim Mueller <wadim.mueller@continental-corporation.com>" "--graph" "--decorate")
  ("-n256" "--author=Marek Vasut <marex@denx.de>" "--graph" "--decorate")
  ("-n256" "--author=Linus Torvalds <torvalds@linux-foundation.org>" "--date-order" "--graph" "--decorate")
  ("-n256" "--author=Shunsuke Mie <mie@igel.co.jp>" "--graph" "--decorate")
  nil)
 (magit-log:-G "qqqq")
 (magit-merge nil)
 (magit-patch nil)
 (magit-patch-apply
  ("--index" "--3way"))
 (magit-patch-create nil)
 (magit-pull nil)
 (magit-push nil)
 (magit-rebase
  ("--autostash"))
 (magit-revert
  ("--edit"))
 (magit-stash nil
	      ("--include-untracked")
	      ("--all"))
 (magit:-- "configs/am64x_evm_a53_defconfig" "l" "" "src/base/tool/il/adapt/ftp_media/lshape/images/bl-lshape-rcar_m3n-integrity.iio" "src/base/pkg/lifecycle/lc-rstp-sync/src/lc-rstp-sync.cpp" "src/base/pkg/reincarnate/cfg/reinarnate.sdh" "src/base/pkg/ospm/CMakeLists.txt" "scripts/build.py,")
 (magit:--author "Wadim Mueller <wafgo01@gmail.com>" "Sergej Lopatin <Sergej.Lopatin@continental-corporation.com>" "Wadim Mueller <wadim.mueller@continental-corporation.com>" "Marek Vasut <marex@denx.de>" "Linus Torvalds <torvalds@linux-foundation.org>" "Shunsuke Mie <mie@igel.co.jp>" "Cristian02 Lupu <cristian.2.lupu@continental-corporation.com>"))
