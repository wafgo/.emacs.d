# Mail-Setup — Emacs-notmuch für Linux-Kernel-Mail

Ersatz für neomutt: Lesen und Versenden von Linux-Kernel-Mails (Schwerpunkt IIO) direkt aus Emacs mit notmuch, mbsync, msmtp und piem.

Tastenbindungen: **`C-c m`** öffnet notmuch, **`C-c p`** ruft piem-dispatch auf.

---

## Setup reproduzieren

Diese Anleitung stellt das komplette Mail-Setup auf einer neuen Maschine wieder her.

### 1. Pakete installieren

Fedora (getestet):

    sudo dnf install isync msmtp lei b4 notmuch emacs-notmuch

**Hinweis:** `lei` ist ein eigenständiges Paket (früher in `public-inbox` enthalten, jetzt separat). `piem` ist in KEINEM ELPA-Archiv (weder MELPA noch NonGNU ELPA) — es wird in Schritt 6 installiert.

### 2. Gmail-App-Passwort verschlüsseln

Gmail verlangt ein App-Passwort (reguläres Passwort funktioniert nicht). Lege es GPG-verschlüsselt ab:

    mkdir -p ~/.config/neomutt
    echo -n "DEIN-APP-PASSWORT" | gpg2 --encrypt --recipient wafgo01@gmail.com -o ~/.config/neomutt/gmail-pass.gpg

**ACHTUNG:** Das Passwort darf niemals ins Repository gelangen. Es liegt ausschließlich in `~/.config/neomutt/gmail-pass.gpg`.

### 3. Konfigurationsdateien kopieren

Dieses Repository enthält geprüfte Kopien. Stelle sie wieder her:

    mkdir -p ~/Mail/.notmuch/hooks ~/.local/bin ~/.config/systemd/user
    
    cp mbsyncrc ~/.mbsyncrc
    cp msmtprc ~/.msmtprc
    cp notmuch-config ~/.notmuch-config
    cp notmuch-hook-post-new ~/Mail/.notmuch/hooks/post-new
    cp mailsync ~/.local/bin/mailsync
    cp mailsync.service ~/.config/systemd/user/mailsync.service
    cp mailsync.timer ~/.config/systemd/user/mailsync.timer

### 4. Dateiberechtigungen setzen

Ohne korrekte Rechte verweigern mbsync und msmtp den Dienst:

    chmod 600 ~/.mbsyncrc
    chmod 600 ~/.msmtprc
    chmod 755 ~/.local/bin/mailsync
    chmod 755 ~/Mail/.notmuch/hooks/post-new

### 5. gpg-agent konfigurieren (zwingend!)

Ohne Cache hängt der systemd-Timer an einem unsichtbaren Passphrase-Prompt und der Mailabruf steht still. Füge zu `~/.gnupg/gpg-agent.conf` hinzu (oder erstelle die Datei):

    default-cache-ttl 86400
    max-cache-ttl 86400

Danach neu laden:

    gpgconf --reload gpg-agent

**Dies ist der häufigste Stolperstein:** ohne ihn scheitert der automatisierte Mailabruf stumm.

### 6. Erstmalige Synchronisation

Initialisiere die notmuch-Datenbank und synchronisiere:

    notmuch new
    mbsync gmail
    notmuch new

Du wirst beim ersten `mbsync` nach der Passphrase für `gmail-pass.gpg` gefragt. Bei korrektem gpg-agent-Cache musst du sie danach 24 Stunden lang nicht mehr eingeben.

### 7. systemd-Timer aktivieren

Der Timer synchronisiert alle 5 Minuten automatisch:

    systemctl --user daemon-reload
    systemctl --user enable --now mailsync.timer

Prüfung:

    systemctl --user is-active mailsync.timer
    # Ausgabe: active

### 8. piem installieren

`piem` ist in keinem Paketarchiv. `lisp/mail-config.el` installiert es automatisch beim ersten Emacs-Start, alternativ manuell:

    M-x package-vc-install RET https://git.kyleam.com/piem RET

---

## Bedienung

- **`C-c m`** — notmuch öffnen
- **`C-c p`** — piem-dispatch (Patch aus Mail anwenden, Branch erstellen)
- In der Suchansicht: `RET` öffnen, `a` archivieren, `r` antworten, `R` an alle antworten, `m` neue Nachricht

---

## Bekannte Stolpersteine

**1. gpg-agent-Cache fehlt**  
Ohne `default-cache-ttl` und `max-cache-ttl` in `~/.gnupg/gpg-agent.conf` hängt der systemd-Timer bei jedem Lauf am Passphrase-Prompt, ohne sichtbare Fehlermeldung. Mailabruf steht still, aber `systemctl --user is-active mailsync.timer` zeigt `active`. Lösung: siehe Schritt 5.

**2. Deutschsprachige Gmail-Ordnernamen**  
Gmail verwendet deutsche Namen: `[Gmail]/Gesendet`, `[Gmail]/Entwürfe`, `[Gmail]/Papierkorb`. Die englischen Namen (`[Gmail]/Sent`, `[Gmail]/Drafts`, `[Gmail]/Trash`) existieren als fast leere Altlasten — würde man die synchronisieren, laufen die Mails am Postfach vorbei. `.mbsyncrc` synchronisiert bewusst die deutschen Namen.

**3. piem liegt in keinem ELPA-Archiv**  
Weder MELPA noch NonGNU ELPA noch GNU ELPA noch Fedora enthalten piem. Es wird per `package-vc-install` von https://git.kyleam.com/piem geholt (siehe Schritt 8). Bei Netzwerkproblemen während des ersten Emacs-Starts kann die Installation fehlschlagen — dann manuell wiederholen.

**4. Gmail-App-Passwort nicht ins Repository**  
Das Passwort liegt ausschließlich in `~/.config/neomutt/gmail-pass.gpg` (GPG-verschlüsselt). Es darf niemals committet werden. `.mbsyncrc` und `.msmtprc` enthalten nur den Befehl `gpg2 -dq ~/.config/neomutt/gmail-pass.gpg`.

**5. Löschen wirkt sich auf Gmail aus**  
`Expunge Both` in `.mbsyncrc` bedeutet: was lokal gelöscht wird, verschwindet beim nächsten Sync auch bei Gmail. Das ist gewollt (bidirektionale Synchronisation).

**6. notmuch löscht nichts**  
`notmuch tag +deleted` entfernt nur aus der Ansicht. Tatsächliches Löschen erfordert Verschieben nach `~/Mail/gmail/Trash` (z.B. mit `mv` oder einem notmuch-Hook).

---

## Diagnose

Timer-Status:

    systemctl --user is-active mailsync.timer
    systemctl --user list-timers mailsync.timer

Letzte Sync-Läufe:

    journalctl --user -u mailsync.service -n 50

msmtp-Versandlog:

    tail ~/.cache/msmtp.log

Datenbank neu indizieren (wenn Tags fehlen):

    notmuch new

---

## Dateien in diesem Verzeichnis

| Datei | Zielort | Rechte |
|---|---|---|
| `mbsyncrc` | `~/.mbsyncrc` | 600 |
| `msmtprc` | `~/.msmtprc` | 600 |
| `notmuch-config` | `~/.notmuch-config` | 644 |
| `notmuch-hook-post-new` | `~/Mail/.notmuch/hooks/post-new` | 755 |
| `mailsync` | `~/.local/bin/mailsync` | 755 |
| `mailsync.service` | `~/.config/systemd/user/mailsync.service` | 644 |
| `mailsync.timer` | `~/.config/systemd/user/mailsync.timer` | 644 |

Design-Dokumentation: `../specs/2026-08-07-emacs-kernel-mail-design.md`
