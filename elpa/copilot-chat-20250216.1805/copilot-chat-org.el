;;; copilot-chat --- copilot-chat-org.el --- copilot chat interface, org frontend -*- indent-tabs-mode: nil; lisp-indent-offset: 2; lexical-binding: t -*-

;; Copyright (C) 2024  copilot-chat maintainers

;; The MIT License (MIT)

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:


;;; Code:

(require 'org)
(require 'copilot-chat-common)
(require 'polymode)

;;; Constants
(defconst copilot-chat--org-input-tag
  "copilotChatInput"
  "The tag used to identify copilot chat input.")
(defconst copilot-chat--org-delimiter
  (concat "* ╭──── Chat Input ────╮ :" copilot-chat--org-input-tag ":")
  "The delimiter used to identify copilot chat input.")

;;; Polymode
(define-derived-mode copilot-chat-org-prompt-mode org-mode "Copilot Chat org Prompt"
  "Major mode for the Copilot Chat Prompt region."
  (setq major-mode 'copilot-chat-org-prompt-mode
    mode-name "Copilot Chat org prompt")
  (copilot-chat-prompt-mode))

(define-hostmode poly-copilot-org-hostmode
  :mode 'org-mode)

(define-innermode poly-copilot-org-prompt-innermode
  :mode 'copilot-chat-org-prompt-mode
  :head-matcher (concat copilot-chat--org-delimiter "\n")
  :tail-matcher "\\'"
  :head-mode 'host
  :tail-mode 'host)

(define-polymode copilot-chat-org-poly-mode
  :hostmode 'poly-copilot-org-hostmode
  :innermodes '(poly-copilot-org-prompt-innermode))


;;; Functions
(defun copilot-chat--org-format-data(content type)
  "Format data for org frontend.
Argument CONTENT is the data to format.
Argument TYPE is the type of the data (prompt or answer)."
  (let ((data ""))
    (if (eq type 'prompt)
	  (progn
	    (setq copilot-chat--first-word-answer t)
	    (setq data (concat "\n* " (format-time-string "*[%T]* You                 :you:\n") (format "%s\n" content))))
	  (when copilot-chat--first-word-answer
	    (setq copilot-chat--first-word-answer nil)
        (setq data (concat "\n** " (format-time-string "*[%T]* Copilot                 :copilot:\n"))))
	  (setq data (concat data content)))
    data))

(defun copilot-chat--org-format-code(code language)
  "Format code for org frontend.
Argument CODE is the code to format.
Argument LANGUAGE is the language of the code."
  (if language
    (format "\n#+BEGIN_SRC %s\n%s\n#+END_SRC\n" language code)
    code))

(defun copilot-chat--org-create-req (prompt &optional no-context)
  "Create a request with org-mode syntax reminder.
PROMPT is the input text.
NO-CONTEXT is an optional flag (unused in current implementation)."
  (format "%s\n\nUse only Emacs org-mode formatting in your answers:
- Use ~*~ for headers (starting at level 3 with ~***~)
- Use ~+~ for unordered lists
- Use ~1.~ for ordered lists
- Use ~=~ or ~~ for inline code
- Use ~#+BEGIN_QUOTE~ and ~#+END_QUOTE~ for quotes
- Use ~#+BEGIN_SRC~ and ~#+END_SRC~ for code blocks with language specification
- Use ~_~ for underlining
- Use ~*~ for bold
- Use ~/~ for italics" prompt))

(defun copilot-chat--org-clean()
  "Clean the copilot chat org frontend.")

(defun copilot-chat--get-org-block-content-at-point ()
  "Get the content of the org block at point."
  (let* ((element (org-element-at-point))
         (type (org-element-type element)))
    (when (memq type '(src-block quote-block example-block))
      (let ((content (org-element-property :value element)))
        content))))

(defun copilot-chat--get-language-mode (element)
  "Get major mode name from org source block language."
  (when (eq (org-element-type element) 'src-block)
    (let ((language (org-element-property :language element)))
      (org-src-get-lang-mode language))))

(defun copilot-chat--find-matching-buffer (mode)
  "Find most recent buffer with major-mode matching MODE."
  (seq-find (lambda (buf)
              (with-current-buffer buf
                (eq major-mode mode)))
            (buffer-list)))

(defun copilot-chat--org-send-to-buffer ()
  "Send the code block at point to buffer.
Replace selection if any."
  (let* ((element (org-element-at-point))
          (mode (copilot-chat--get-language-mode element))
          (matching-buffer (when mode (copilot-chat--find-matching-buffer mode)))
          (default-buffer (or matching-buffer (current-buffer)))
          (buffer (completing-read "Choose buffer: "
                    (mapcar #'buffer-name (buffer-list))
                    nil  ; PREDICATE
                    t    ; REQUIRE-MATCH
                    nil  ; INITIAL-INPUT
                    'buffer-name-history
                    (buffer-name default-buffer)))
          (content (copilot-chat--get-org-block-content-at-point)))
    (when content
      (with-current-buffer buffer
        (when (use-region-p)
          (delete-region (region-beginning) (region-end)))
        (insert content))
      (let ((window (get-buffer-window buffer)))
        (if window
          (select-window window)
          (switch-to-buffer buffer))))))

(defun copilot-chat--org-get-code-blocks-under-heading (heading-regex)
  "Get source blocks under headings matching HEADING-REGEX."
  (let ((blocks))
    (org-map-entries
      (lambda ()
        (let* ((heading-end (save-excursion (org-end-of-subtree t)))
                (element-start (point)))
          (setq blocks
            (append blocks
              (org-element-map
                (org-element-parse-buffer 'element)
                'src-block
                (lambda (src-block)
                  (when (and (>= (org-element-property :begin src-block) element-start)
                          (<= (org-element-property :begin src-block) heading-end))
                    (list :language (org-element-property :language src-block)
                      :content (org-element-property :value src-block)
                      :begin (org-element-property :begin src-block)
                      :end (org-element-property :end src-block)))))))))
      heading-regex)
    (seq-uniq blocks #'equal)))

(defun copilot-chat--org-yank()
  (let ((content ""))
	(with-current-buffer copilot-chat--buffer
	  (let ((blocks (copilot-chat--org-get-code-blocks-under-heading "copilot")))
        (when blocks
		  (while (< copilot-chat--yank-index 1)
			(setq copilot-chat--yank-index (+ (length blocks)
                                             copilot-chat--yank-index)))
          (when (> copilot-chat--yank-index (length blocks))
			(setq copilot-chat--yank-index (- copilot-chat--yank-index
                                             (length blocks))))
		  (setq content (plist-get (car (last blocks copilot-chat--yank-index)) :content)))))
	;; Delete previous yank if exists
    (when (and copilot-chat--last-yank-start
               copilot-chat--last-yank-end)
	  (delete-region copilot-chat--last-yank-start copilot-chat--last-yank-end))
    ;; Insert new content
    (setq copilot-chat--last-yank-start (point))
    (insert content)
    (setq copilot-chat--last-yank-end (point))))

(defun copilot-chat--org-write(data)
  "Write data at the end of the chat part of the buffer."
  (copilot-chat--org-goto-input)
  (forward-line -3)
  (end-of-line)
  (insert data))


(defun copilot-chat--org-goto-input()
  "Go to the input part of the chat buffer.
The input is created if not found."
  (goto-char (point-max))
  (let ((span (pm-innermost-span (point))))
    (if (and span
          (not (eq (car span) nil)))  ; nil span-type means host mode
      (goto-char (+ 1 (car (pm-innermost-range (point)))))
      (insert "\n\n")
      (let ((start (point))
             (inhibit-read-only t))
        (insert copilot-chat--org-delimiter "\n\n")
        (add-text-properties start (point)
          '(read-only t front-sticky t rear-nonsticky (read-only)))))))

(defun copilot-chat--org-get-buffer()
  "Create copilot-chat buffers."
  (unless (buffer-live-p copilot-chat--buffer)
    (setq copilot-chat--buffer (get-buffer-create copilot-chat--buffer-name))
    (with-current-buffer copilot-chat--buffer
      (copilot-chat-org-poly-mode)
      (copilot-chat--org-goto-input)))
  copilot-chat--buffer)

(defun copilot-chat--org-insert-prompt (prompt)
    "Insert PROMPT in the chat buffer."
  (with-current-buffer (copilot-chat--org-get-buffer)
    (copilot-chat--org-goto-input)
    (unless (eobp)
      (delete-region (point) (point-max)))
    (insert prompt)))

(defun copilot-chat--org-pop-prompt()
  "Get current prompt to send and clean it."
  (with-current-buffer (copilot-chat--org-get-buffer)
    (copilot-chat--org-goto-input)
    (let ((prompt (buffer-substring (point) (point-max))))
      (delete-region (point) (point-max))
      prompt)))

(defun copilot-chat--org-init()
  "Initialize the copilot chat org frontend."
  (setq copilot-chat-prompt copilot-chat-org-prompt))

(provide 'copilot-chat-org)
;;; copilot-chat-org.el ends here
