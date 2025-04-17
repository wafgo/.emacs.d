;;; copilot-chat --- copilot-chat-common.el --- copilot chat variables and const -*- indent-tabs-mode: nil; lexical-binding:t -*-

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
;; All shared variables and constants

;;; Code:

(require 'json)
(require 'cl-lib)

;; constants
(defconst copilot-chat--magic "#cc#done#!$")
(defconst copilot-chat--buffer-name "*Copilot-chat*")

;; customs
(defgroup copilot-chat nil
  "GitHub Copilot chat."
  :group 'tools)

(defcustom copilot-chat-frontend 'org
  "Frontend to use with `copilot-chat'.  Can be org or markdown."
  :type '(choice (const :tag "org-mode" org)
                 (const :tag "markdown" markdown)
                 (const :tag "shell-maker" shell-maker))
  :group 'copilot-chat)

(defcustom copilot-chat-github-token-file "~/.config/copilot-chat/github-token"
  "The file where to find GitHub token."
  :type 'string
  :group 'copilot-chat)

(defcustom copilot-chat-token-cache "~/.cache/copilot-chat/token"
  "The file where the GitHub token is cached."
  :type 'string
  :group 'copilot-chat)

;;  OpenAI models: https://platform.openai.com/docs/models
(defcustom copilot-chat-model "gpt-4o"
  "The model to use for Copilot chat."
  :type '(choice (const :tag "GPT-4o" "gpt-4o")
                 (const :tag "Claude 3.5 Sonnet" "claude-3.5-sonnet")
                 (const :tag "GPT-4o1-(preview)" "o1-preview"))
  :group 'copilot-chat)

(defcustom copilot-chat-prompt-suffix nil
  "Suffix to be added to the end of the prompt before sending to Copilot Chat. For Example: Reply in Chinese (or any other language)
If nil, no suffix will be added."
  :type 'string
  :group 'copilot-chat)

;; structs
(cl-defstruct copilot-chat
  ready
  github-token
  token
  sessionid
  machineid
  history
  buffers)

(cl-defstruct copilot-chat-frontend
  id
  init-fn
  clean-fn
  format-fn
  format-code-fn
  create-req-fn
  send-to-buffer-fn
  yank-fn
  write-fn
  get-buffer-fn
  insert-prompt-fn
  pop-prompt-fn
  goto-input-fn)

;; variables
(defvar copilot-chat--instance
  (make-copilot-chat
   :ready nil
   :github-token nil
   :token nil
   :sessionid nil
   :machineid nil
   :history nil
   :buffers nil))

(defvar copilot-chat--frontend-list
  (list (make-copilot-chat-frontend
         :id 'markdown
         :init-fn #'copilot-chat--markdown-init
         :clean-fn #'copilot-chat--markdown-clean
         :format-fn #'copilot-chat--markdown-format-data
         :format-code-fn #'copilot-chat--markdown-format-code
         :create-req-fn nil
         :send-to-buffer-fn #'copilot-chat--markdown-send-to-buffer
         :yank-fn nil
         :write-fn #'copilot-chat--markdown-write
         :get-buffer-fn #'copilot-chat--markdown-get-buffer
         :insert-prompt-fn #'copilot-chat--markdown-insert-prompt
         :pop-prompt-fn #'copilot-chat--markdown-pop-prompt
         :goto-input-fn #'copilot-chat--markdown-goto-input)
        (make-copilot-chat-frontend
         :id 'org
         :init-fn #'copilot-chat--org-init
         :clean-fn #'copilot-chat--org-clean
         :format-fn #'copilot-chat--org-format-data
         :format-code-fn #'copilot-chat--org-format-code
         :create-req-fn #'copilot-chat--org-create-req
         :send-to-buffer-fn #'copilot-chat--org-send-to-buffer
         :yank-fn #'copilot-chat--org-yank
         :write-fn #'copilot-chat--org-write
         :get-buffer-fn #'copilot-chat--org-get-buffer
         :insert-prompt-fn #'copilot-chat--org-insert-prompt
         :pop-prompt-fn #'copilot-chat--org-pop-prompt
         :goto-input-fn #'copilot-chat--org-goto-input)
        (make-copilot-chat-frontend
         :id 'shell-maker
         :init-fn #'copilot-chat-shell-maker-init
         :clean-fn #'copilot-chat--shell-maker-clean
         :format-fn nil
         :format-code-fn #'copilot-chat--markdown-format-code
         :create-req-fn nil
         :send-to-buffer-fn nil
         :yank-fn nil
         :write-fn nil
         :get-buffer-fn #'copilot-chat--shell-maker-get-buffer
         :insert-prompt-fn #'copilot-chat--shell-maker-insert-prompt
         :pop-prompt-fn nil
         :goto-input-fn nil))
    "Copilot-chat frontends and functions list.")

(defvar copilot-chat--buffer nil)

(defvar copilot-chat--first-word-answer t)

(defvar copilot-chat--yank-index 1
  "Next index to yank")
(defvar copilot-chat--last-yank-start nil
  "Start position of last yank")
(defvar copilot-chat--last-yank-end nil
  "End position of last yank")

;; Functions
(defun copilot-chat--uuid ()
  "Generate a UUID."
  (format "%04x%04x-%04x-4%03x-%04x-%04x%04x%04x"
          (random 65536) (random 65536)
          (random 65536)
          (logior (random 16384) 16384)
          (logior (random 4096) 32768)
          (random 65536) (random 65536) (random 65536)))

(defun copilot-chat--machine-id ()
  "Generate a machine ID."
  (let ((hex-chars "0123456789abcdef")
        (length 65)
        (hex ""))
    (dotimes (_ length)
      (setq hex (concat hex (string (aref hex-chars (random 16))))))
    hex))

(defun copilot-chat--create-req(prompt no-context)
  "Create a request for Copilot.
Argument PROMPT Copilot prompt to send.
Argument NOCONTEXT tells copilot-chat to not send history and buffers.
The create req function is called first and will return new prompt."
  (let ((create-req-fn (copilot-chat-frontend-create-req-fn (copilot-chat--get-frontend)))
        (messages nil))
    (when create-req-fn
      (setq prompt (funcall create-req-fn prompt no-context)))

    ;; user prompt
    (push (list (cons "content" prompt) (cons "role" "user")) messages)

    (unless no-context
      ;; history
      (dolist (history (copilot-chat-history copilot-chat--instance))
        (push (list (cons "content" (car history)) (cons "role" (cadr history))) messages))
      ;; buffers
      (setf (copilot-chat-buffers copilot-chat--instance) (cl-remove-if (lambda (buf) (not (buffer-live-p buf)))
                                                                        (copilot-chat-buffers copilot-chat--instance)))
      (dolist (buffer (copilot-chat-buffers copilot-chat--instance))
        (when (buffer-live-p buffer)
          (with-current-buffer buffer
            (push (list (cons "content" (buffer-substring-no-properties (point-min) (point-max))) (cons "role" "user")) messages)))))

    ;; system
    (push (list (cons "content" copilot-chat-prompt) (cons "role" "system")) messages)

    (json-encode `(("messages" . ,(vconcat messages))
                   ("top_p" . 1)
                   ("model" . ,copilot-chat-model)
                   ("stream" . t)
                   ("n" . 1)
                   ("intent" . t)
                   ("temperature" . 0.1)))))

(defun copilot-chat--get-frontend()
  (cl-find copilot-chat-frontend copilot-chat--frontend-list
           :key #'copilot-chat-frontend-id
           :test #'eq))

(provide 'copilot-chat-common)
;;; copilot-chat-common.el ends here
