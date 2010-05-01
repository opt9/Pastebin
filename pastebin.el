;;; pastebin.el --- Emacs integration for pastebin.com

;; Copyright (C) 2010 Jeremy Bae <swbae@naver.com>

;; Version: 0.1
;; Keywords: paste pastebin
;; Created: 01 May 2010
;; Author: Jeremy Bae <swbae@naver.com>

;; This file is NOT part of GNU Emacs.

;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.
;;
;; This is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.

;;; Commentary:

;; pastebin.el provides functions to post a region or buffer to
;; <http://pastebin.com> and put the paste URL into the kill-ring.

;; Modified dpaste.el of Greg Newman <grep@20seven.org> to pastebin.el

;; Installation and setup:

;; Put this file in a directory where Emacs can find it. On GNU/Linux
;; it's usually /usr/local/share/emacs/site-lisp/ and on Windows it's
;; something like "C:\Program Files\Emacs<version>\site-lisp". Then
;; add the follow instructions in your .emacs.el:

;;     (require 'pastebin nil)
;;     (global-set-key (kbd "C-c p") 'pastebin-region-or-buffer)

;; Then with C-c p you can run `pastebin-region-or-buffer'.

;; Todo:

;;; Code:
(defvar paste_name "pastebin.el"
  "Paste author name or e-mail. Don't put more than 30 characters here.")

(defvar pastebin-supported-modes-alist '((css-mode . "css")
                                       (diff-mode . "dff")
                                       (html-mode . "html4strict")
                                       (scheme-mode . "scheme")
                                       (inferior-scheme-mode . "scheme")
                                       (lisp-mode . "lisp")
                                       (inferior-lisp-mode . "lisp")
                                       (emacs-lisp-mode . "lisp")
                                       (inferior-emacs-lisp-mode . "lisp")
                                       (perl-mode . "perl")
                                       (cperl-mode . "perl")
                                       (sh-mode . "bash")
                                       (tcl-mode . "tcl")
                                       (java-mode . "java")
                                       (c-mode . "cpp")
                                       (latex-mode . "latex")
                                       (makefile-mode . "make")
                                       (xml-mode . "xml")))


;;;###autoload
(defun pastebin-region (begin end title &optional arg)
  "Post the current region or buffer to pastebin.com and yank the
url to the kill-ring.

With a prefix argument, use hold option."
  (interactive "r\nsPaste title: \nP")
  (let* ((file (or (buffer-file-name) (buffer-name)))
         (name (file-name-nondirectory file))
         (lang (or (cdr (assoc major-mode pastebin-supported-modes-alist))
                  ""))
         (output (generate-new-buffer "*pastebin*")))
    (shell-command-on-region begin end
			     (concat "curl -si"
				     " -H 'Host: pastebin.com'"
                                     " -F 'paste_code=<-'"
                                     " -F 'paste_format=" lang "'"
                                     " -F 'paste_name=" title "'"
                                     " -F 'paste_expire_date=10M'"
                                     " http://89.185.229.72/api_public.php")
			     output)
    (with-current-buffer output
      (search-forward-regexp "^\\(http://pastebin\\.com/?[a-zA-Z0-9]+\\)")
      (message "Paste created: %s (yanked)" (match-string 1))
      (kill-new (match-string 1)))
    (kill-buffer output)))

;;;###autoload
(defun pastebin-buffer (title &optional arg)
  "Post the current buffer to pastebin.com and yank the url to the
kill-ring."
  (interactive "sPaste title: \nP")
  (pastebin-region (point-min) (point-max) title arg))

;;;###autoload
(defun pastebin-region-or-buffer (title &optional arg)
  "Post the current region or buffer to pastebin.com and yank the
url to the kill-ring."
  (interactive "sPaste title: \nP")
  (condition-case nil
      (pastebin-region (point) (mark) title arg)
    (mark-inactive (pastebin-buffer title arg))))


(provide 'pastebin)
;;; pastebin.el ends here.
