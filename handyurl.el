;;; handyurl.el --- Pop up a list of URLs and select for pasting.
;; Copyright 1998-2017 by Dave Pearson <davep@davep.org>

;; Author: Dave Pearson <davep@davep.org>
;; Version: 1.11
;; Keywords: convenience, quoting
;; URL: https://github.com/davep/handyurl.el
;; Package-Requires: ((cl-lib "0.5"))

;; handyurl.el is free software distributed under the terms of the GNU
;; General Public Licence, version 2 or (at your option) any later version.
;; For details see the file COPYING.

;;; Commentary:
;;
;; This package provides a simple method of popping up a list of URLs and
;; allowing the selection and insertion of an URL into the previous buffer.
;;
;; The URLs are stored in an external file as a list of cons cells, for example:
;;
;; (( "The GNU Project" . "http://www.gnu.org/")
;;  ( "The FSF"         . "http://www.fsf.org/"))
;;
;; The name and location of the file is up to you, the default name used by
;; the function `handy-url' is stored in `handy-url-file'.

(eval-when-compile
  (require 'cl))

;;; Code:

(defvar handy-url-file "~/.handy-urls"
  "*Name of file from which `handy-url' should read the URLs.")

(defvar handy-url-mode-hook nil
  "*Hooks for `handy-url-mode'.")

(defvar handy-url-sort-predicate #'(lambda (first second)
                                     (string< (upcase (car first))
                                              (upcase (car second))))
  "*Predicate for sorting the URLs before display.

Setting this variable to NIL means \"don't sort\".")

(defvar handy-url-urls nil
  "Contains the list of URL details.")

(defvar handy-url-last-buffer nil
  "Pointer to the calling buffer.")

(defvar handy-url-mode-map nil
  "Local keymap for the `handy-url' buffer.")

(defvar handy-url-buffer-name "*Handy-URL*"
  "Name for the URL listing buffer.")

(unless handy-url-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map t)
    (define-key map [(control m)] #'handy-url-insert-url)
    (define-key map "u"           #'handy-url-insert-naked-url)
    (define-key map " "           #'handy-url-insert-url-with-name)
    (define-key map "n"           #'handy-url-insert-name)
    (define-key map [(control g)] #'handy-url-select-quit)
    (define-key map "q"           #'handy-url-select-quit)
    (define-key map "?"           #'describe-mode)
    (setq handy-url-mode-map map)))

(put 'handy-url-mode 'mode-class 'special)

(defun handy-url-mode ()
  "A mode for use with `handy-url'.

The key bindings for `handy-url-mode' are:

\\{handy-url-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map handy-url-mode-map)
  (setq major-mode 'handy-url-mode
	mode-name  "Handy URL")
  (run-hooks 'handy-url-mode-hook)
  (setq buffer-read-only t))

;;;###autoload
(defun* handy-url (&optional (url-file handy-url-file))
  "Pick an URL from a list of URLs and paste it into the current buffer.
URL-FILE is the name of the file to read the URL list from, if not supplied
the file pointed to by `handy-url-file' is read."
  (interactive)
  (unless (string= (buffer-name) handy-url-buffer-name)
    (setq handy-url-last-buffer (current-buffer)))
  (if (file-exists-p url-file)
      (progn
	(pop-to-buffer "*Handy-URL*")
        (let ((buffer-read-only nil))
          (setf (buffer-string) "")
          (handy-url-read-urls url-file)
          (handy-url-display-urls)
          (setf (point) (point-min)))
        (handy-url-mode))
    (error "No such URL file '%s'" url-file)))

(defun handy-url-read-urls (url-file)
  "Read the URLS into the variable `handy-url-urls'.

Argument URL-FILE is the name of the file to read."
  (with-temp-buffer
    (insert-file-contents url-file t)
    (setq handy-url-urls (read (current-buffer))))
  (when handy-url-sort-predicate
    (setq handy-url-urls (sort handy-url-urls handy-url-sort-predicate))))

(defun handy-url-display-urls ()
  "Display the contans of `handy-url-urls' in the current buffer."
  (let ((fmt (format "%%-%ds - %%s\n"
                     (apply #'max (loop for url in handy-url-urls
                                        collect (length (car url)))))))
    (loop for url in handy-url-urls
          do (insert (format fmt (car url) (cdr url))))))

(defun handy-url-current-line ()
  "Work out the current line number."
  (save-excursion
    (beginning-of-line)
    (let ((line-point (point)))
      (setf (point) (point-min))
      (loop while (< (point) line-point) sum 1 do (forward-line 1)))))

(defun handy-url-insert (type)
  "Paste the url under the customer to the current buffer.

TYPE specifies the kind of formatting to apply."
  (let ((url (nth (handy-url-current-line) handy-url-urls)))
    (if url
	(with-current-buffer handy-url-last-buffer
	  (insert (case type
                    ('url       (format "<URL:%s>" (cdr url)))
                    ('naked-url (cdr url))
                    ('with-name (format "%s <URL:%s>" (car url) (cdr url)))
                    ('name      (car url)))))
      (error "No URL details on that line"))
    url))

(defun handy-url-insert-url ()
  "Insert the selected URL into the buffer."
  (interactive)
  (when (handy-url-insert 'url)
    (handy-url-select-quit)))

(defun handy-url-insert-naked-url ()
  "Insert the selected URL into the buffer (with no formatting)."
  (interactive)
  (when (handy-url-insert 'naked-url)
    (handy-url-select-quit)))

(defun handy-url-insert-url-with-name ()
  "Insert the site name and the URL."
  (interactive)
  (when (handy-url-insert 'with-name)
    (handy-url-select-quit)))

(defun handy-url-insert-name ()
  "Insert the name of the site."
  (interactive)
  (when (handy-url-insert 'name)
    (handy-url-select-quit)))

(defun handy-url-select-quit ()
  "Kill the Handy-URL frame."
  (interactive)
  (kill-buffer handy-url-buffer-name)
  (switch-to-buffer handy-url-last-buffer)
  (delete-other-windows))

(provide 'handyurl)

;;; handyurl.el ends here
