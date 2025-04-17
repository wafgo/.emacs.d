;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "magit" "20250204.1930"
  "A Git porcelain inside Emacs."
  '((emacs         "27.1")
    (compat        "30.0.2.0")
    (llama         "0.6.0")
    (magit-section "4.3.0")
    (seq           "2.24")
    (transient     "0.8.4")
    (with-editor   "3.4.3"))
  :url "https://github.com/magit/magit"
  :commit "7298daa607f5c9597d537b73c14bc924b6a5d290"
  :revdesc "7298daa607f5"
  :keywords '("git" "tools" "vc")
  :authors '(("Marius Vollmer" . "marius.vollmer@gmail.com")
             ("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev"))
  :maintainers '(("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev")
                 ("Kyle Meyer" . "kyle@kyleam.com")))
