;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)

(package! org-journal
  :recipe (:fetcher github :repo "emacs-packages/org-journal" :branch "private" :files ("*")))

(package! pyim)

(package! pyim-wbdict)

(package! dictionary
  :recipe (:fetcher github :repo "emacs-packages/dictionary" :files ("*")))
