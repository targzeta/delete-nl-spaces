;;; delete-nl-spaces.el --- deleting needless spaces from buffers
;;
;; Copyright (C) 2014-2017 Emanuele Tomasi <targzeta@gmail.com>
;;
;; Author: Emanuele Tomasi <targzeta@gmail.com>
;; URL: https://github.com/targzeta/delete-nl-spaces
;; Maintainer: Emanuele Tomasi <targzeta@gmail.com>
;; Keywords: convenience, whitespace
;; Version: 1.0
;;
;; This file is NOT part of GNU Emacs.
;;
;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; This minor mode, enabled by default on every new buffers, deletes
;; unnecessary spaces from a buffer before that it's saved to its file.
;;
;; When you visit a file, if its buffer is cleaned then this minor mode will
;; be enable, otherwise will be disable.
;;
;; You can clean a buffer also calling the `delete-nl-spaces' interactive
;; function.
;;
;; The `delete-nl-spaces':
;; - deletes initial blank lines;
;; - changes spaces on tabs or vice versa depending on `indent-tabs-mode';
;; - deletes the trailing whitespaces and empty last lines;
;; - deletes also latest blank line if `require-final-newline' is nil;"
;;
;;; Usage:
;;
;; Copy this file in a directory which is in the Emacs `load-path'. Then,
;; execute the following code either directly or in your .emacs file:
;; (require 'delete-nl-spaces)
;;
;;; Code:

(define-minor-mode delete-nl-spaces-mode
  "Toggle deleting needless spaces (Delete Needless Spaces mode).
With a prefix argument ARG, enable Delete Needless Spaces mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil.

If Delete Needless Spaces mode is enable, before a buffer is saved to its file:
- delete initial blank lines;
- change spaces on tabs or vice versa depending on `indent-tabs-mode';
- delete the trailing whitespaces and empty last lines;
- delete also latest blank line if `require-final-newline' is nil;"
  :init-value t
  :lighter " dns")

(defun delete-nl-spaces ()
  "Execute `delete-nl-spaces'."
  (if delete-nl-spaces-mode
      (save-excursion
        ;; Delete initial blank lines
        (goto-char (point-min))
        (skip-chars-forward " \n\t")
        (skip-chars-backward " \t")
        (if (> (point) 0)
            (delete-char (- (- (point) 1))))

        ;; Change spaces on tabs or tabs on spaces
        (if indent-tabs-mode
            (tabify (point-min) (point-max))
          (untabify (point-min) (point-max)))

        ;; Delete the trailing whitespaces and all blank lines
        (let ((delete-trailing-lines t))
          (delete-trailing-whitespace))

        ;; Delete the latest newline
        (unless require-final-newline
          (goto-char (point-max))
          (let ((trailnewlines (skip-chars-backward "\n\t")))
            (if (< trailnewlines 0)
                (delete-char (abs trailnewlines))))))))

(defun delete-nl-spaces-find-file-hook ()
  "Check whether to disable `delete-nl-spaces'."
  (when (and (buffer-file-name) (file-exists-p (buffer-file-name)))
    (let ((buffer (current-buffer))
          (final-newline require-final-newline)
          (tabs-mode indent-tabs-mode))
      (with-temp-buffer
        (setq-local require-final-newline final-newline)
        (setq indent-tabs-mode tabs-mode)
        (insert-buffer-substring buffer)
        (delete-nl-spaces)
        (unless (= (compare-buffer-substrings buffer nil nil nil nil nil) 0)
          (set-buffer buffer)
          (delete-nl-spaces-mode -1)
          (message "delete-nl-spaces-mode disabed for %s"
                   (buffer-name buffer)))))))

(add-hook 'find-file-hook 'delete-nl-spaces-find-file-hook)
(add-hook 'before-save-hook 'delete-nl-spaces)

(provide 'delete-nl-spaces)

;;; delete-nl-spaces.el ends here
