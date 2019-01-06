;;; ~/.doom.d/autoload.el -*- lexical-binding: t; -*-


;;;###autoload
(defun +comment-dwim (&optional arg)
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))


;;;###autoload
(defun +frame-clean ()
  "Close all other windows , and than display the spacemacs buffer."
  (interactive)
  (delete-other-windows)
  (switch-to-buffer "*doom*"))


;;;###autoload
(defun +ediff-dotfile-and-template ()
  "ediff the current `dotfile' with the template"
  (interactive)
  (ediff-files
   "~/.doom.d/init.el"
   "~/.emacs.d/init.example.el"))


;;;###autoload
(defun +ispell-alternate-dictionary/install ()
  "Install english words dictionary."
  (interactive)
  (if (file-exists-p ispell-alternate-dictionary)
      (user-error "ispell-alternate-dictionary already installed")
    (copy-file (concat quelpa-dir "/build/dictionary/English-words.txt")
               ispell-alternate-dictionary)))
