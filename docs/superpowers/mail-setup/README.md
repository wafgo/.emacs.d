# Mail-Setup

Kopien der Konfiguration aus dem Emacs-Mail-Setup. Die Originale liegen
ausserhalb dieses Repositories; diese Kopien dienen der Reproduzierbarkeit.

| Datei hier | Zielort | Rechte |
|---|---|---|
| `mbsyncrc` | `~/.mbsyncrc` | 600 |
| `msmtprc` | `~/.msmtprc` | 600 |
| `notmuch-config` | `~/.notmuch-config` | 644 |
| `notmuch-hook-post-new` | `~/Mail/.notmuch/hooks/post-new` | 755 |
| `mailsync` | `~/.local/bin/mailsync` | 755 |
| `mailsync.service` | `~/.config/systemd/user/mailsync.service` | 644 |
| `mailsync.timer` | `~/.config/systemd/user/mailsync.timer` | 644 |

Das Gmail-App-Passwort liegt GPG-verschluesselt in
`~/.config/neomutt/gmail-pass.gpg` und wird von mbsync und msmtp per
`gpg2 -dq` gelesen. Es ist hier bewusst nicht abgelegt.

Benoetigte Pakete: `isync msmtp lei b4 emacs-notmuch notmuch`, dazu `piem`
aus MELPA.

Design: `../specs/2026-08-07-emacs-kernel-mail-design.md`

## Bedienung

- `C-c m` — notmuch oeffnen
- `C-c p` — piem-Menue (Patch aus Mail anwenden)
- In der Suchansicht: `RET` oeffnen, `a` archivieren, `r` antworten,
  `R` an alle antworten, `m` neue Nachricht

## Diagnose

    journalctl --user -u mailsync.service -n 50
    systemctl --user list-timers mailsync.timer
    tail ~/.cache/msmtp.log
