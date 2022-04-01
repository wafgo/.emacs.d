(define-package "jupyter" "20220212.210" "Jupyter"
  '((emacs "26")
    (zmq "0.10.3")
    (cl-lib "0.5")
    (simple-httpd "1.5.0")
    (websocket "1.9"))
  :commit "0a7055d7b12cf98723110415b08ee91869fa7d94" :authors
  '(("Nathaniel Nicandro" . "nathanielnicandro@gmail.com"))
  :maintainer
  '("Nathaniel Nicandro" . "nathanielnicandro@gmail.com")
  :url "https://github.com/dzop/emacs-jupyter")
;; Local Variables:
;; no-byte-compile: t
;; End:
