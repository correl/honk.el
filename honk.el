;;; honk.el --- Bad Goose -*- lexical-binding: t; -*-
;; Copyright (C) 2015-2019, Correl Roush

;; Author: Correl Roush <correl@gmail.com>
;; URL: https://github.com/correl/honk.el
;; Version: 1.0
;; Keywords: honk, goose
;; Package-Requires: (emms)

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; honk.el harasses you with honking every hour. It's possibly the worst (or
;; best) way to know the hour.
;;
;; Put this file into your load-path and the following into your ~/.emacs:
;;	 (require 'honk)
;;
;;; Code:

(require 'emms-source-file)
(require 'emms-playlist-mode)

(defconst *honk-directory* (file-name-directory (or load-file-name buffer-file-name))
  "Where the goose lives.")

(defvar *honk-mp3* (concat *honk-directory* "honk.mp3")
  "Path to the honk mp3 file.")

(defvar *honk-timer* nil
  "Timer to honk hourly.")

(defun honk-the-hour ()
  "Honk the hour. More hours, more honks.

It's particularly evil, as it'll take over your EMMS playlist,
trashing it in the process, and doing its own thing."
  (interactive)
  (progn
    (setq emms-repeat-track nil
          emms-repeat-playlist nil)
    (emms-playlist-current-clear)
    (let ((current-hour (nth 2 (decode-time (current-time)))))
      (cl-dotimes (i current-hour)
        (emms-add-file *honk-mp3*)))

    (with-current-emms-playlist
      (goto-line 1)
      (emms-playlist-mode-play-smart))))

(defun honk-hourly ()
  "Honk every hour, on the hour."
  (interactive)
  (unless *honk-timer*
    (let* ((now (decode-time (current-time)))
           (next-hour
            (time-add (encode-time
                       0
                       0
                       (nth 2 now)
                       (nth 3 now)
                       (nth 4 now)
                       (nth 5 now))
                      3600)))
      (setq *honk-timer*
            (run-at-time next-hour 3600 #'honk-the-hour)))))

(defun honk-stop ()
  "Cancel the hourly honk timer."
  (interactive)
  (when *honk-timer*
    (cancel-timer *honk-timer*)
    (setq *honk-timer* nil)))

(provide 'honk)
;;; honk.el ends here
