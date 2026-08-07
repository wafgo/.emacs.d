;;; mail-config.el --- Mail-Setup fuer Kernel-Arbeit  -*- lexical-binding: t; -*-

;;; Commentary:
;; notmuch als Oberflaeche, msmtp fuer den Versand.
;; Siehe docs/superpowers/specs/2026-08-07-emacs-kernel-mail-design.md

;;; Code:

(require 'notmuch)
(require 'message)
(require 'sendmail)

;;; Identitaet

(setq user-full-name "Wadim Mueller"
      user-mail-address "wafgo01@gmail.com")

;;; Versand ueber msmtp

(setq send-mail-function #'message-send-mail-with-sendmail
      message-send-mail-function #'message-send-mail-with-sendmail
      sendmail-program "/usr/bin/msmtp"
      message-sendmail-f-is-evil t
      message-sendmail-extra-arguments '("--read-envelope-from")
      message-sendmail-envelope-from 'header
      mail-specify-envelope-from t
      mail-envelope-from 'header)

;;; Kernel-Mail-Hygiene
;; Kein format=flowed, kein HTML, harte Umbrueche bei 72 Zeichen.

(setq message-default-charset 'utf-8
      message-fill-column 72
      message-citation-line-format "On %Y-%m-%d %R, %N wrote:\n"
      message-citation-line-function #'message-insert-formatted-citation-line
      message-kill-buffer-on-exit t
      message-confirm-send t)

(defun kernel-mail--plain-text-setup ()
  "Harte Zeilenumbrueche statt format=flowed erzwingen."
  (setq-local fill-column 72)
  (turn-off-auto-fill)
  (setq-local use-hard-newlines nil)
  (setq-local mml-enable-flowed nil))

(add-hook 'message-mode-hook #'kernel-mail--plain-text-setup)

;;; Gesendete Nachrichten in den lokalen Maildir schreiben,
;;; mbsync schiebt sie beim naechsten Lauf zu Gmail hoch.

(setq notmuch-fcc-dirs "gmail/Sent")

;;; notmuch-Grundverhalten

(setq notmuch-search-oldest-first nil
      notmuch-show-logo nil
      notmuch-archive-tags '("-inbox" "-unread")
      notmuch-show-all-tags-list t)

;;; Gespeicherte Suchen — ersetzen die Ordner-Sidebar aus neomutt

(setq notmuch-saved-searches
      '((:name "Inbox"          :query "tag:inbox"                            :key "i")
        (:name "Ungelesen"      :query "tag:inbox and tag:unread"             :key "u")
        (:name "An mich"        :query "tag:to-me and tag:inbox"              :key "m")
        (:name "IIO"            :query "tag:iio or tag:lore"                  :key "I")
        (:name "IIO ungelesen"  :query "(tag:iio or tag:lore) and tag:unread" :key "U")
        (:name "Patches"        :query "tag:patch and date:2weeks.."          :key "p")
        (:name "LKML"           :query "tag:lkml and date:1week.."            :key "l")
        (:name "Gesendet"       :query "tag:sent"                             :key "s")
        (:name "Entwuerfe"      :query "tag:draft"                            :key "d")
        (:name "Alles"          :query "*"                                    :key "a")))

(setq notmuch-saved-search-sort-function nil)

(global-set-key (kbd "C-c m") #'notmuch)

(provide 'mail-config)
;;; mail-config.el ends here
