;;; speech-to-text-nerd-dictation.el --- Speech to text using nerd-dictation

;; Copyright (C) 2025- Vladimir Stavrov

;; Author&Maintainer: https://github.com/v1st-git
;; Version: 1.0
;; Package-Requires: ((emacs "24.3"))
;; Keywords: convenience, speech recognition
;; URL: https://github.com/v1st-git/emacs-text-to-speech-locally

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides an interface to start nerd-dictation and insert recognized text
;; into the current buffer.

;;; Code:

(defgroup speech-to-text-nerd-dictation nil
  "Options for Speech to Text using Nerd-Dictation."
  :group 'convenience)

(defcustom s2tnd-path "~/NLP/text2speech/vosk/nerd-dictation/"
  "Path to the nerd-dictation application."
  :type 'directory
  :group 'speech-to-text-nerd-dictation)

(defcustom s2tnd-options '(("--timeout" . "2.0") ("--output" . "STDOUT"))
  "List of options for nerd-dictation as alist (key . value)."
  :type '(repeat (cons string string))
  :group 'speech-to-text-nerd-dictation)

(defun speech-to-text-nerd-dictation ()
  "Press hotkey(s) to start nerd-dictation listener, then say whatever is needed.
Recognized text will be inserted after the current point of the current buffer."
  (interactive)
  (let* ((current-buffer (buffer-name))
         (current-point (point))
         (command
          (concat s2tnd-path "nerd-dictation begin "
                  (mapconcat #'(lambda (opt)
				 (format "%s=%s" (car opt) (cdr opt))) s2tnd-options " "))))
    (message (format "Say something after beep sound, finish by 2-sec pause" (beep)))
    (let ((text-from-audio
           (shell-command-to-string command)))
      (with-current-buffer current-buffer
        (insert text-from-audio)
	;; remove trailing 'the', occasionally inserted by nerd-dictation
        (when (string= (thing-at-point 'word t) "the")
          (delete-region (- (point) 3) (point)))
	;; display intro message if there were no recognized text after starting beep sound
	(when (< (count-words current-point (point)) 2)
	  (message
	   (concat "Say at least a couple of words after pressing of "
		   (replace-regexp-in-string
		    (format "%s[[:space:]]+is[[:space:]]+on[[:space:]]"
			    'speech-to-text-nerd-dictation)
		    ""
		    (with-output-to-string (where-is 'speech-to-text-nerd-dictation)))
		   " to audio input/mic, "
		   "recognized text will be inserted to current buffer"))
	  (delete-region current-point (point)))
	))))

(provide 'speech-to-text-nerd-dictation)

;;; speech-to-text-nerd-dictation.el ends here
