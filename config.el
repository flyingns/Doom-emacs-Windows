;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here


;;; emacs basic configuration


;; frame maximized
(add-hook 'window-setup-hook #'toggle-frame-maximized)


;; fonts
(when IS-WINDOWS
  (defun set-font (english chinese english-size chinese-size)
    (set-face-attribute 'default nil :font
                        (format   "%s:pixelsize=%d"  english english-size))
    (dolist (charset '(kana han symbol cjk-misc bopomofo))
      (set-fontset-font (frame-parameter nil 'font) charset
                        (font-spec :family chinese :size chinese-size))))
  (set-font "Source Code Pro" "simsun" 12 14)
  )


;; coding system
(when IS-WINDOWS
  (set-selection-coding-system 'utf-16le-dos))


;; time locale
(setq system-time-locale "C")


;; mouse scroll
(setq mouse-wheel-scroll-amount '(1 ((shift) . 3))
      mouse-wheel-progressive-speed nil)


;;; private userdata directory

(defconst home-root-directory "~/"
  "Home directory .")

(defconst emacs-env-directory
  (expand-file-name (concat home-root-directory "env/"))
  "Doom-emacs env directory.")

(defconst dictionary-directory
  (expand-file-name (concat home-root-directory "dict/"))
  "Dictionary directory.")
(unless (file-exists-p dictionary-directory)
  (make-directory dictionary-directory))

(defconst userdata-root-directory
  (expand-file-name (concat home-root-directory ".source/"))
  "Userdata root directory.")

(defconst userdata-archives-directory
  (expand-file-name (concat userdata-root-directory "archives/"))
  "Userdata archives directory.")

(defconst userdata-projects-directory
  (expand-file-name (concat userdata-root-directory "projects/"))
  "Userdata projects directory.")

(defconst userdata-journal-directory
  (expand-file-name (concat userdata-root-directory "journal/"))
  "Userdata journal directory.")

(defconst userdata-notes-directory
  (expand-file-name (concat userdata-root-directory "notes/"))
  "Userdata notes directory.")

(defconst userdata-org-directory
  (expand-file-name (concat userdata-root-directory "org/"))
  "Userdata org directory.")

(defconst userdata-private-directory
  (expand-file-name (concat userdata-root-directory "private/"))
  "Userdata private directory.")


;;; epa ( GnuPG 1.4 )

(require 'epa-file)
(setq epa-pinentry-mode nil
      epa-file-select-keys 0
      epa-file-cache-passphrase-for-symmetric-encryption t
      epa-file-inhibit-auto-save nil)


;;; ispell

(require 'ispell)

;; Install : +ispell-alternate-dictionary/install
(setq ispell-alternate-dictionary
      (concat dictionary-directory "English-words.txt"))


;;; doom-modeline

(when (featurep! :ui doom-modeline)
  (setq +doom-modeline-buffer-file-name-style 'file-name))


;;; popup

;; default
(setq +popup-defaults
      (list :side 'bottom
            :height 0.25
            :width 0.5
            :quit t
            :select #'ignore
            :ttl 5))

;; python
(after! python
  (set-popup-rule! "^\\*Python" :side 'right :size 0.5 :select nil :quit t))

(after! python
  (unless (file-directory-p conda-anaconda-home)
    (make-directory conda-anaconda-home))
  (unless (file-directory-p conda-env-home-directory)
    (make-directory conda-env-home-directory)))


;; diary ( launch the calendar and press d to display a diary )
(after! calendar
  (set-popup-rule! "^\\*Fancy Diary Entries" :side 'right :size 0.5 :quit t))


;;; Markdown

;; markdown-workflow : 1 . C-c C-c l
;;                     2 . C-x C-s

(when (featurep! :lang markdown)
  (setq markdown-command "pandoc -f markdown -t html"))

;;; LaTeX

;; TeX-workflow : 1. SPC m b : M-x latex/build
;;                2. SPC m v : M-x TeX-view

(add-hook 'TeX-mode-hook
          (lambda ()
            (setq TeX-auto-untabify t
                  TeX-engine 'XeTeX
                  TeX-command-extra-options "-file-line-error -shell-escape"
                  TeX-command-default "XeLaTeX"
                  TeX-save-query nil
                  TeX-show-compilation t)
            (TeX-global-PDF-mode t)
            (imenu-add-menubar-index)
            (add-to-list 'TeX-command-list
                         '("XeLaTeX" "%`xelatex --synctex=1%(mode)%' %t" TeX-run-TeX nil t))))

;; TeX view
(setq TeX-view-program-selection '((output-pdf "PDF Tools"))
      TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
      TeX-source-correlate-start-server t)

;; spellchecking can be slow in TeX buffers
(setq-hook! 'TeX-mode-hook +spellcheck-immediately nil)

;; latex/build
(defvar latex-build-command
  (if (executable-find "xelatex") "XeLaTeX" "LatexMK" "LaTeX"))

(defun latex/build ()
  (interactive)
  (progn
    (let ((TeX-save-query nil))
      (TeX-save-document (TeX-master-file)))
    (TeX-command latex-build-command 'TeX-master-file -1)))

(add-hook 'TeX-mode-hook
          (lambda ()
            (map! :map TeX-mode-map
                  :localleader
                  :nv "b" #'latex/build
                  :nv "v" #'TeX-view
                  :nv "TAB" #'TeX-complete-symbol)))


;;; RSS

(add-hook 'elfeed-search-mode-hook
          (lambda ()
            (setq line-spacing 0.3
                  browse-url-browser-function 'eww-browse-url)))


;;; deft

(after! deft
  (setq deft-directory userdata-notes-directory))


;;; pyim

(def-package! pyim
  :demand t

  :config
  (setq pyim-dcache-directory (expand-file-name "pyim/dcache" doom-local-dir)
        default-input-method "pyim"
        pyim-default-scheme 'wubi)

  (setq-default pyim-english-input-switch-functions
                '(pyim-probe-dynamic-english
                  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation))

  (setq pyim-page-tooltip 'posframe
        pyim-page-length 5
        pyim-page-style 'vertical)

  :bind
  (("M-j" . pyim-convert-code-at-point)
   ("C-;" . pyim-delete-word-from-personal-buffer))
  )

(after! pyim
  (pyim-wbdict-v98-enable)
  (toggle-input-method)
  (run-with-timer 15 nil
                  (lambda () (cd "~"))))


;;; org-mode

(add-hook 'org-mode-hook
          (lambda () (setq truncate-lines nil)))

(setq org-directory userdata-org-directory
      org-enforce-todo-dependencies t
      org-tags-match-list-sublevels 'indented
      org-log-into-drawer t
      org-log-done 'time
      org-log-note-clock-out t
      org-log-redeadline t
      org-log-reschedule t
      org-ellipsis " ▼ "
      org-agenda-files (list org-directory))

(after! org
  (dolist (face '(org-level-1
                  org-level-2 org-level-3
                  org-level-4 org-level-5
                  org-level-6 org-level-7
                  org-level-8))
    (set-face-attribute face nil :weight 'normal :height 1.0 ))
  )


;; diary

(setq diary-file
      (expand-file-name "diary" org-directory))

;; org-refile

(setq org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes 'confirm)

(defadvice org-refile (after save-all-after-refile activate)
  "Save all org buffers after each refile operation."
  (org-save-all-org-buffers))

;; org-todo-keywords

(after! org
  (setq org-todo-keywords
        '((sequence "[ ](t!)" "[-](p!)" "[?](m@/!)" "|" "[X](d@/!)")
          (sequence "TODO(T!)" "|" "DONE(D!)")
          (sequence "NEXT(n!)" "WAITING(w@/!)" "LATER(l!)" "|" "CANCELLED(c@/!)"))))

;; org-journal

(def-package! org-journal
  :after org)

(setq org-journal-dir userdata-journal-directory
      org-journal-enable-agenda-integration t
      org-journal-carryover-items nil)

;; org-capture-files

(defun +browse-org-capture-todo-file ()
  (interactive)
  (find-file +org-capture-todo-file))

(defun +browse-org-capture-notes-file ()
  (interactive)
  (find-file +org-capture-notes-file))

;; private memo org file

(setq org-private-memo-file
      (expand-file-name
       (concat org-directory "memo.org")))

(defun +browse-org-private-memo-file ()
  (interactive)
  (find-file org-private-memo-file))

;; org-capture-templates

(add-to-list 'org-capture-templates
             `("~n" "notes.org" plain (file +org-capture-notes-file)
               ,(concat "#+FILETAGS: :inbox:note:\n"
                        "#+TAGS\n\n\n"
                        "* Inbox\n\n\n"
                        "%?")))

(add-to-list 'org-capture-templates
             `("~t" "todo.org" plain (file +org-capture-todo-file)
               ,(concat "#+FILETAGS: :inbox:todo:\n"
                        "#+TAGS\n\n\n"
                        "* Inbox\n\n\n"
                        "%?")))

(add-to-list 'org-capture-templates
             `("~m" "memo.org" plain (file org-private-memo-file)
               ,(concat "#+FILETAGS: :memo:\n"
                        "#+TAGS\n\n\n"
                        "* Tasks\n\n\n"
                        "* Memo\n\n\n"
                        "* Book\n\n\n"
                        "** Finished :read:\n\n\n"
                        "** Reading :reading:\n\n\n"
                        "** Booklist :booklist:\n\n\n"
                        "* Refile\n\n\n"
                        "%?")))

(add-to-list 'org-capture-templates '("~" "Initialization"))

(add-to-list 'org-capture-templates
             '("a" "Attendance" entry
               (file+headline +org-capture-notes-file "Inbox")
               "* %u %^{Note}\n%?"
               :prepend t :kill-buffer t))

(after! org-journal

  (add-to-list 'org-capture-templates
               '("jc" "Journal credit payment logs" entry
                 (function org-journal-find-location)
                 "* [ ] %^{Note} :journal:credit:\nDEADLINE: %^{Deadline}t\nEntered on %U\n"
                 :prepend t :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("jw" "Journal work logs" entry
                 (function org-journal-find-location)
                 "* TODO [#B] %^{Note} :journal:work:\nSCHEDULED: %T DEADLINE: %^{Deadline}u\n%?"
                 :prepend t :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("ji" "Journal idea" entry
                 (function org-journal-find-location)
                 "* [ ] %^{Note} :journal:idea:\nEntered on %U\n"
                 :prepend t :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("jn" "Journal notes" entry
                 (function org-journal-find-location)
                 "* %^{Title} :journal:note:\nEntered on %U\n%?"
                 :prepend t :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("jm" "journal memo" entry
                 (function org-journal-find-location)
                 "* %^{Note} :journal:memo:\nEntered on %U\n"
                 :prepend t :kill-buffer t))

  (add-to-list 'org-capture-templates '("j" "Journal")))


;; org-agenda-custom-commands

(setq org-agenda-custom-commands
      '(

        ("n" "Agenda and all TODOs"
         (
          (agenda "")
          (alltodo "")
          ))

        ("w" "Works agenda"
         (
          (tags-todo "+journal+work")
          ))

        ("r" . "Review inbox and journal")
        ("rt" "inbox todo" tags "+inbox+todo")
        ("rn" "inbox note" tags "+inbox+note")
        ("rT" "journal idea" tags "+journal+idea")
        ("rN" "journal note" tags "+journal+note")
        ("rM" "journal memo" tags "+journal+memo")
        ("rC" "journal credit payment logs" tags "+journal+credit")

        ("R" "Reading"
         (
          (tags "+memo+reading")
          (tags "+memo+booklist")
          (tags "+memo+read")
          ))

        ("A" "Attendance"
         (
          (tags "+memo+attendance")
          ))

        ("P" "All TODOs sort by Priority"
         (
          (tags-todo "+PRIORITY=\"A\"")
          (tags-todo "+PRIORITY=\"B\"")
          (tags-todo "+PRIORITY=\"C\"")
          ))

        ))


;;; Private keybinds

(map! :leader

      (:prefix ("k" . "Private keybinds")

        :desc "Calendar"               "c"        #'calendar

        :desc "Org decrypt entry"      "K"        #'org-decrypt-entry
        :desc "Ace swap window"        "s"        #'ace-swap-window
        :desc "Discover projects"      "P"        #'projectile-discover-projects-in-directory

        :desc "Clean frame"            "x"        #'+frame-clean
        :desc "Comment"                ";"        #'+comment-dwim
        :desc "Ediff configuration"    "D"        #'+ediff-dotfile-and-template

        (:prefix ("o" . "open")
          :desc "Org store line"       "l"        #'org-store-link
          :desc "Org switchb"          "s"        #'org-switchb
          :desc "Org agenda"           "a"        #'org-agenda)

        (:prefix ("b" . "browse-files")
          :desc "Browse todo file"     "t"        #'+browse-org-capture-todo-file
          :desc "Browse notes file"    "n"        #'+browse-org-capture-notes-file
          :desc "Browse memo file"     "m"        #'+browse-org-private-memo-file)

        (:prefix ("E" . "elfeed")
          :desc "Elfeed"               "e"        #'elfeed
          :desc "Elfeed update"        "u"        #'elfeed-update)

        )
      )

(after! org-journal
  (map! :leader
        (:prefix "k"
          (:prefix ("j" . "org-journal")
            :desc "New entry"                   "C-n"        #'org-journal-new-entry
            :desc "New date entry"              "C-d"        #'org-journal-new-date-entry
            :desc "New schedule entry"          "C-s"        #'org-journal-new-scheduled-entry
            :desc "Journal search forver"       "s"          #'org-journal-search-forever
            :desc "Journal schedule view"       "v"          #'org-journal-schedule-view))))

(map! :localleader

      (:after python
        :map python-mode-map
        "r"        #'run-python)

      )
