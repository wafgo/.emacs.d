# Emacs-Mail-Setup für Kernel-Entwicklung — Implementierungsplan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** neomutt durch einen Emacs-basierten Mail-Workflow ersetzen, mit dem Kernel-Mails gelesen, durchsucht und Patches versendet werden können.

**Architecture:** `mbsync` synchronisiert Gmail in den lokalen Maildir `~/Mail`, `lei` legt lore.kernel.org-Suchergebnisse daneben, `notmuch` indiziert beides, `notmuch-emacs` ist die Bedienoberfläche, `msmtp` versendet für Emacs und `git send-email` gleichermaßen, `piem` holt Patch-Serien aus Mails ins Kernel-Repo.

**Tech Stack:** Fedora 41, Emacs 30.2 (`package.el` + `use-package`), notmuch 0.38.3, isync 1.5.0, msmtp 1.8.25, lei 2.0.0, b4 0.14.2, piem (MELPA)

## Global Constraints

- Absenderadresse für alle Kernel-Mails: `wafgo01@gmail.com`
- Credential-Quelle ausschließlich: `gpg2 -dq ~/.config/neomutt/gmail-pass.gpg`
- Maildir-Root: `~/Mail`; notmuch-Datenbank darunter in `~/Mail/.notmuch`
- Gmail „All Mail" (`[Gmail]/All Mail`) wird niemals synchronisiert
- neomutt und seine Konfiguration bleiben unverändert und funktionsfähig
- Emacs-Mail-Konfiguration liegt isoliert in `~/.emacs.d/lisp/mail-config.el`; `init.el` wird nur um eine einzige `require`-Zeile ergänzt
- Kernel-Mail-Hygiene: `text/plain`, kein `format=flowed`, `fill-column` 72
- Commits erfolgen im Repo `~/.emacs.d`, jeweils mit explizitem Pathspec (`git commit -- <datei>`), weil dort bereits fremde Änderungen gestaget sind. Niemals `git add -A` oder `git commit -a` verwenden.
- Alle Commit-Messages enden mit `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`

## Dateiübersicht

| Datei | Verantwortung | Task |
|---|---|---|
| `~/.mbsyncrc` | Gmail-IMAP ↔ `~/Mail/gmail/` | 2 |
| `~/.notmuch-config` | Indexer-Konfiguration, Identität | 3 |
| `~/Mail/.notmuch/hooks/post-new` | Automatisches Tagging | 4 |
| `~/.local/bin/mailsync` | Sync-Orchestrierung | 6 |
| `~/.config/systemd/user/mailsync.service` | systemd-Unit | 7 |
| `~/.config/systemd/user/mailsync.timer` | Zeitsteuerung | 7 |
| `~/.msmtprc` | SMTP-Versand | 8 |
| `~/.emacs.d/lisp/mail-config.el` | Emacs: notmuch, message-mode, piem | 9, 10, 11 |
| `~/.emacs.d/init.el` | Einbindung von `mail-config.el` | 9 |
| `~/.gitconfig` | `send-email` über msmtp, Absenderidentität | 8 |

Da diese Dateien überwiegend außerhalb von `~/.emacs.d` liegen und nicht
versioniert werden, hält Task 12 Kopien der Konfigurationen im Repo vor, damit
das Setup reproduzierbar bleibt.

## Testansatz

Es gibt hier kein Test-Framework — die Deliverables sind Konfigurationsdateien.
Jede Aufgabe hat deshalb ein konkretes, ausführbares Prüfkommando mit erwarteter
Ausgabe. Die Regel bleibt dieselbe wie bei TDD: **erst das Prüfkommando
ausführen und scheitern sehen, dann konfigurieren, dann erneut prüfen.**

---

### Task 1: Pakete installieren

**Files:** keine

**Interfaces:**
- Produces: die Binaries `/usr/bin/mbsync`, `/usr/bin/msmtp`, `/usr/bin/lei`, `/usr/bin/b4` und die Emacs-Bibliothek `/usr/share/emacs/site-lisp/notmuch.el`

- [ ] **Step 1: Prüfen, dass die Werkzeuge fehlen**

```bash
for t in mbsync msmtp lei b4; do printf '%s: ' "$t"; command -v $t || echo FEHLT; done
ls /usr/share/emacs/site-lisp/notmuch.el 2>/dev/null || echo "notmuch.el FEHLT"
```

Erwartet: alle vier melden `FEHLT`, ebenso `notmuch.el`.

- [ ] **Step 2: Pakete installieren**

`lei` ist ein eigenständiges Paket und **nicht** in `public-inbox` enthalten —
`public-inbox` wird hier nicht gebraucht. Das Emacs-Frontend für notmuch heißt
`emacs-notmuch`.

```bash
sudo dnf install -y isync msmtp lei b4 emacs-notmuch
```

- [ ] **Step 3: Installation verifizieren**

```bash
for t in mbsync msmtp lei b4; do printf '%s: ' "$t"; command -v $t || echo FEHLT; done
ls /usr/share/emacs/site-lisp/notmuch.el
```

Erwartet: vier Pfade unter `/usr/bin/`, kein `FEHLT`, und `notmuch.el` existiert.

- [ ] **Step 4: GPG-Zugriff auf das Passwort prüfen**

```bash
gpg2 -dq ~/.config/neomutt/gmail-pass.gpg | wc -c
```

Erwartet: eine Zahl größer 0 (das entschlüsselte Passwort). Der `gpg-agent`
fragt eventuell nach der Passphrase — das ist in Ordnung und muss
funktionieren, bevor es weitergeht. Schlägt das fehl, ist der Rest des Plans
blockiert.

---

### Task 2: mbsync konfigurieren und Gmail synchronisieren

**Files:**
- Create: `~/.mbsyncrc`
- Create (Verzeichnis): `~/Mail/gmail/`

**Interfaces:**
- Consumes: `mbsync` aus Task 1, `gmail-pass.gpg`
- Produces: Maildir `~/Mail/gmail/` mit den Unterordnern `INBOX`, `Sent`, `Drafts`, `Trash`; mbsync-Channel-Gruppe `gmail`, aufrufbar über `mbsync gmail`

- [ ] **Step 1: Prüfen, dass noch nichts existiert**

```bash
ls ~/.mbsyncrc 2>/dev/null || echo "keine mbsyncrc"
ls ~/Mail 2>/dev/null || echo "kein Maildir"
```

Erwartet: beide Meldungen erscheinen.

- [ ] **Step 2: Maildir anlegen**

```bash
mkdir -p ~/Mail/gmail
chmod 700 ~/Mail
```

- [ ] **Step 3: `~/.mbsyncrc` schreiben**

`SubFolders Verbatim` sorgt dafür, dass Gmails Ordner mit Leerzeichen und
eckigen Klammern nicht in eine Ordnerhierarchie zerlegt werden. Jeder Channel
benennt genau einen Ordner — „All Mail" bleibt bewusst außen vor, weil Gmail
dort jede Nachricht ein zweites Mal führt.

```
# ~/.mbsyncrc — Gmail <-> ~/Mail/gmail

IMAPAccount gmail
Host imap.gmail.com
Port 993
User wafgo01@gmail.com
PassCmd "gpg2 -dq ~/.config/neomutt/gmail-pass.gpg"
TLSType IMAPS
TLSVersions +1.2
CertificateFile /etc/ssl/certs/ca-bundle.crt

IMAPStore gmail-remote
Account gmail

MaildirStore gmail-local
Path ~/Mail/gmail/
Inbox ~/Mail/gmail/INBOX
SubFolders Verbatim

Channel gmail-inbox
Far :gmail-remote:"INBOX"
Near :gmail-local:"INBOX"
Create Both
Expunge Both
SyncState *

Channel gmail-sent
Far :gmail-remote:"[Gmail]/Sent Mail"
Near :gmail-local:"Sent"
Create Both
Expunge Both
SyncState *

Channel gmail-drafts
Far :gmail-remote:"[Gmail]/Drafts"
Near :gmail-local:"Drafts"
Create Both
Expunge Both
SyncState *

Channel gmail-trash
Far :gmail-remote:"[Gmail]/Trash"
Near :gmail-local:"Trash"
Create Both
Expunge Both
SyncState *

Group gmail
Channel gmail-inbox
Channel gmail-sent
Channel gmail-drafts
Channel gmail-trash
```

- [ ] **Step 4: Rechte setzen und Konfiguration testen**

```bash
chmod 600 ~/.mbsyncrc
mbsync --list gmail
```

Erwartet: eine Liste der vier Ordner ohne Fehlermeldung. Erscheint
`Authentication failed`, stimmt das App-Passwort nicht; erscheint
`No channel or group named gmail`, ist die Datei fehlerhaft.

- [ ] **Step 5: Ersten Sync im Vordergrund laufen lassen**

Das kann je nach Postfachgröße mehrere Minuten dauern und darf nicht abgebrochen
werden.

```bash
mbsync -V gmail
```

- [ ] **Step 6: Ergebnis prüfen**

```bash
ls ~/Mail/gmail/
find ~/Mail/gmail/INBOX/cur -type f | wc -l
```

Erwartet: die Ordner `INBOX`, `Sent`, `Drafts`, `Trash`; die Dateizahl in
`INBOX/cur` ist größer 0.

- [ ] **Step 7: Sicherstellen, dass „All Mail" nicht gelandet ist**

```bash
ls ~/Mail/gmail/ | grep -i "all" && echo "FEHLER: All Mail wurde gesynct" || echo "ok"
```

Erwartet: `ok`.

---

### Task 3: notmuch konfigurieren und erstmalig indizieren

**Files:**
- Create: `~/.notmuch-config`

**Interfaces:**
- Consumes: Maildir aus Task 2
- Produces: notmuch-Datenbank unter `~/Mail/.notmuch`; das Tag `new` markiert Nachrichten, die der Hook aus Task 4 noch verarbeiten muss

- [ ] **Step 1: Prüfen, dass notmuch unkonfiguriert ist**

```bash
notmuch count 2>&1 | head -3
```

Erwartet: eine Fehlermeldung über eine fehlende Konfiguration oder Datenbank.

- [ ] **Step 2: `~/.notmuch-config` schreiben**

`new.tags` wird auf `new` gesetzt statt auf die Vorgabe `unread;inbox`, damit der
Hook aus Task 4 selbst entscheidet, was in die Inbox gehört — sonst landen auch
alle lore-Nachrichten dort.

```
[database]
path=/home/sefo/Mail

[user]
name=Wadim Mueller
primary_email=wafgo01@gmail.com
other_email=wadim.mueller@cmblu.de

[new]
tags=new
ignore=.mbsyncstate;.uidvalidity;.mbsyncstate.new;.mbsyncstate.journal

[search]
exclude_tags=deleted;spam

[maildir]
synchronize_flags=true
```

- [ ] **Step 3: Erstmalig indizieren**

```bash
notmuch new
```

Erwartet: eine Meldung der Form `Added N new messages to the database.`

- [ ] **Step 4: Index prüfen**

```bash
notmuch count
notmuch count tag:new
```

Erwartet: beide Zahlen größer 0 und identisch.

- [ ] **Step 5: Sicherstellen, dass die Absenderadresse erkannt wird**

```bash
notmuch config get user.primary_email
```

Erwartet: `wafgo01@gmail.com`

---

### Task 4: Tagging-Hook einrichten

**Files:**
- Create: `~/Mail/.notmuch/hooks/post-new`

**Interfaces:**
- Consumes: notmuch-Datenbank aus Task 3
- Produces: die Tags `inbox`, `unread`, `to-me`, `sent`, `lkml`, `iio`, `patch`, `lore`; das Tag `new` existiert nach jedem Lauf nicht mehr

- [ ] **Step 1: Prüfen, dass noch keine Tags vergeben sind**

```bash
notmuch search --output=tags '*'
```

Erwartet: im Wesentlichen nur `new` (und ggf. von Maildir-Flags abgeleitete Tags
wie `unread`, `replied`).

- [ ] **Step 2: Hook schreiben**

Die Reihenfolge ist bedeutsam: erst breite Regeln, dann engere. Am Ende wird
`new` entfernt, damit jeder Lauf nur die tatsächlich neuen Nachrichten anfasst.

```bash
#!/bin/bash
# ~/Mail/.notmuch/hooks/post-new
# Vergibt Tags fuer neu indizierte Nachrichten (Tag "new").
set -euo pipefail

# Alles Neue kommt zunaechst in die Inbox und gilt als ungelesen.
notmuch tag +inbox +unread -- tag:new

# Direkt an mich adressiert.
notmuch tag +to-me -- tag:new and \
  '(to:wafgo01@gmail.com or cc:wafgo01@gmail.com or to:wadim.mueller@cmblu.de or cc:wadim.mueller@cmblu.de)'

# Eigene gesendete Nachrichten: nicht in der Inbox, nicht ungelesen.
notmuch tag +sent -inbox -unread -- tag:new and \
  '(from:wafgo01@gmail.com or from:wadim.mueller@cmblu.de)'

# Kernel-Listen.
notmuch tag +lkml -- tag:new and \
  '(to:linux-kernel@vger.kernel.org or cc:linux-kernel@vger.kernel.org)'
notmuch tag +iio -- tag:new and \
  '(to:linux-iio@vger.kernel.org or cc:linux-iio@vger.kernel.org)'

# Patches erkennen: Betreff der Form "[PATCH ...]".
notmuch tag +patch -- tag:new and 'subject:PATCH'

# Nachrichten aus lore-Abfragen: nicht in die Inbox, sonst wird sie unbrauchbar.
notmuch tag +lore -inbox -- tag:new and 'folder:/^lei/'

# Verarbeitung abgeschlossen.
notmuch tag -new -- tag:new
```

- [ ] **Step 3: Ausführbar machen und laufen lassen**

```bash
mkdir -p ~/Mail/.notmuch/hooks
chmod +x ~/Mail/.notmuch/hooks/post-new
~/Mail/.notmuch/hooks/post-new
```

Erwartet: keine Ausgabe, Exit-Code 0.

- [ ] **Step 4: Tags prüfen**

```bash
notmuch count tag:new
notmuch count tag:inbox
notmuch count tag:sent
notmuch search --output=tags '*'
```

Erwartet: `tag:new` ist 0, `tag:inbox` größer 0, und in der Tag-Liste stehen
`inbox`, `unread`, `sent`.

- [ ] **Step 5: Wirksamkeit bei neuen Nachrichten sicherstellen**

```bash
notmuch new
notmuch count tag:new
```

Erwartet: 0 — der Hook läuft automatisch nach `notmuch new` und räumt das Tag ab.

---

### Task 5: lore.kernel.org über lei anbinden

**Files:** keine (lei verwaltet seinen Zustand selbst unter `~/.local/share/lei`)

**Interfaces:**
- Consumes: `lei` aus Task 1, notmuch-Konfiguration aus Task 3
- Produces: Maildir `~/Mail/lei/iio` mit einer gespeicherten, über `lei up` aktualisierbaren Suche

- [ ] **Step 1: Prüfen, dass noch keine Suche existiert**

```bash
lei ls-search
```

Erwartet: leere Ausgabe.

- [ ] **Step 2: Externe Quelle registrieren**

```bash
lei add-external --mirror https://lore.kernel.org/linux-iio/ ~/.local/share/lei/linux-iio
```

Das klont das Archiv der Liste und kann einige Minuten dauern. Falls die
Spiegelung fehlschlägt (kein Speicherplatz, Netzwerkproblem), lässt sich
stattdessen ohne lokalen Spiegel arbeiten:

```bash
lei add-external https://lore.kernel.org/linux-iio/
```

Dann laufen Abfragen über HTTP statt lokal — langsamer, aber funktionsfähig.

- [ ] **Step 3: Externe Quelle prüfen**

```bash
lei ls-external
```

Erwartet: ein Eintrag, der `linux-iio` enthält.

- [ ] **Step 4: Gespeicherte Suche anlegen**

Die Abfrage deckt die Liste selbst sowie Patches ab, die IIO-Dateien berühren
und über andere Listen laufen. `rt:` begrenzt auf die letzten drei Monate, damit
der Erstabruf überschaubar bleibt.

```bash
lei q -o ~/Mail/lei/iio --dedupe=mid --threads \
  '(dfn:drivers/iio/ OR dfn:include/linux/iio/ OR l:linux-iio.vger.kernel.org) AND rt:3.months.ago..'
```

- [ ] **Step 5: Ergebnis prüfen**

```bash
lei ls-search
find ~/Mail/lei/iio -type f | wc -l
```

Erwartet: die Suche wird gelistet, und die Dateizahl ist größer 0.

- [ ] **Step 6: In notmuch aufnehmen**

```bash
notmuch new
notmuch count tag:lore
notmuch count tag:lore and tag:inbox
```

Erwartet: `tag:lore` größer 0 und `tag:lore and tag:inbox` gleich 0 — die
lore-Nachrichten dürfen die Inbox nicht fluten.

Ist die zweite Zahl größer 0, greift die `folder:`-Regel im Hook nicht. Dann den
tatsächlichen Ordnernamen prüfen und die Regel in `~/Mail/.notmuch/hooks/post-new`
entsprechend anpassen:

```bash
notmuch search --output=files --limit=1 tag:lore | head -1
```

- [ ] **Step 7: Aktualisierung testen**

```bash
lei up --all
```

Erwartet: läuft fehlerfrei durch; beim zweiten Lauf direkt hintereinander kommen
keine oder nur wenige neue Nachrichten dazu.

---

### Task 6: Sync-Skript schreiben

**Files:**
- Create: `~/.local/bin/mailsync`

**Interfaces:**
- Consumes: `mbsync gmail` (Task 2), `lei up --all` (Task 5), `notmuch new` (Task 3)
- Produces: das Kommando `~/.local/bin/mailsync`, das Task 7 aus systemd aufruft

- [ ] **Step 1: Prüfen, dass es das Skript nicht gibt**

```bash
ls ~/.local/bin/mailsync 2>/dev/null || echo "kein mailsync"
```

Erwartet: `kein mailsync`.

- [ ] **Step 2: Skript schreiben**

Die Sperrdatei verhindert, dass sich zwei Läufe überlappen, wenn ein Sync
einmal länger dauert als das Timer-Intervall. `lei up` darf fehlschlagen (etwa
bei fehlender Netzwerkverbindung), ohne den Gesamtlauf zu stoppen — die
Gmail-Synchronisation ist wichtiger.

```bash
#!/bin/bash
# ~/.local/bin/mailsync — holt Mail und aktualisiert den notmuch-Index.
set -uo pipefail

LOCK="${XDG_RUNTIME_DIR:-/tmp}/mailsync.lock"
exec 9>"$LOCK"
if ! flock -n 9; then
    echo "mailsync laeuft bereits, Abbruch."
    exit 0
fi

status=0

echo "== mbsync =="
if ! mbsync gmail; then
    echo "mbsync fehlgeschlagen" >&2
    status=1
fi

echo "== lei up =="
if ! lei up --all; then
    echo "lei up fehlgeschlagen (nicht kritisch)" >&2
fi

echo "== notmuch new =="
if ! notmuch new; then
    echo "notmuch new fehlgeschlagen" >&2
    status=1
fi

exit $status
```

- [ ] **Step 3: Ausführbar machen und aufrufen**

```bash
mkdir -p ~/.local/bin
chmod +x ~/.local/bin/mailsync
~/.local/bin/mailsync
```

Erwartet: die drei Abschnittsüberschriften erscheinen, Exit-Code 0.

- [ ] **Step 4: Sperrmechanismus prüfen**

```bash
(~/.local/bin/mailsync >/dev/null &) ; sleep 1 ; ~/.local/bin/mailsync
```

Erwartet: der zweite Aufruf meldet `mailsync laeuft bereits, Abbruch.`

---

### Task 7: systemd-Timer einrichten

**Files:**
- Create: `~/.config/systemd/user/mailsync.service`
- Create: `~/.config/systemd/user/mailsync.timer`

**Interfaces:**
- Consumes: `~/.local/bin/mailsync` aus Task 6
- Produces: einen aktiven Timer, der alle 5 Minuten synchronisiert

- [ ] **Step 1: Prüfen, dass es die Units nicht gibt**

```bash
ls ~/.config/systemd/user/mailsync.* 2>/dev/null || echo "keine Units"
```

Erwartet: `keine Units`.

- [ ] **Step 2: gpg-agent auf Zwischenspeicherung einstellen**

Der Timer läuft ohne Terminal. Fragt `gpg` dort nach der Passphrase, hängt der
Lauf, bis das Timeout greift. Deshalb muss der Agent das Passwort vorhalten.

In `~/.gnupg/gpg-agent.conf` ergänzen (Datei anlegen, falls nicht vorhanden):

```
default-cache-ttl 86400
max-cache-ttl 86400
```

Dann den Agent neu starten und den Cache füllen:

```bash
gpgconf --kill gpg-agent
gpg2 -dq ~/.config/neomutt/gmail-pass.gpg >/dev/null && echo "Cache gefuellt"
```

- [ ] **Step 3: Service-Unit schreiben**

```ini
# ~/.config/systemd/user/mailsync.service
[Unit]
Description=Mail synchronisieren (mbsync + lei + notmuch)
After=network-online.target

[Service]
Type=oneshot
ExecStart=%h/.local/bin/mailsync
TimeoutStartSec=600
```

- [ ] **Step 4: Timer-Unit schreiben**

```ini
# ~/.config/systemd/user/mailsync.timer
[Unit]
Description=Mail alle 5 Minuten synchronisieren

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
AccuracySec=30s
Persistent=true

[Install]
WantedBy=timers.target
```

- [ ] **Step 5: Service einmalig testen**

```bash
systemctl --user daemon-reload
systemctl --user start mailsync.service
systemctl --user status mailsync.service --no-pager
```

Erwartet: `Active: inactive (dead)` mit `status=0/SUCCESS` — bei `Type=oneshot`
ist das der Erfolgsfall.

Bei Fehlern:

```bash
journalctl --user -u mailsync.service -n 30 --no-pager
```

- [ ] **Step 6: Timer aktivieren**

```bash
systemctl --user enable --now mailsync.timer
systemctl --user list-timers mailsync.timer --no-pager
```

Erwartet: der Timer wird mit einem `NEXT`-Zeitpunkt in der Zukunft gelistet.

- [ ] **Step 7: Automatischen Lauf abwarten und bestätigen**

```bash
sleep 330
journalctl --user -u mailsync.service --since "-6 min" --no-pager | tail -20
```

Erwartet: ein Lauf mit den drei Abschnittsüberschriften aus Task 6.

---

### Task 8: msmtp und git send-email einrichten

**Files:**
- Create: `~/.msmtprc`
- Modify: `~/.gitconfig`

**Interfaces:**
- Consumes: `msmtp` aus Task 1, `gmail-pass.gpg`
- Produces: das msmtp-Konto `gmail` als Vorgabe; `sendemail.smtpserver` zeigt auf `/usr/bin/msmtp`. Task 9 nutzt `/usr/bin/msmtp` als `sendmail-program`.

- [ ] **Step 1: Ausgangszustand festhalten**

```bash
ls ~/.msmtprc 2>/dev/null || echo "keine msmtprc"
git config --global --get-regexp 'sendemail|user\.'
```

Erwartet: `keine msmtprc`; bei git stehen `user.email=wadim.mueller@cmblu.de`
und `sendemail.smtpserver=smtp.gmail.com`.

- [ ] **Step 2: `~/.msmtprc` schreiben**

Port 587 mit STARTTLS statt 465, weil `git send-email` und Emacs damit
gleichermaßen zurechtkommen und die bestehende git-Konfiguration diesen Port
bereits nutzte.

```
# ~/.msmtprc
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-bundle.crt
logfile        ~/.cache/msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           wafgo01@gmail.com
user           wafgo01@gmail.com
passwordeval   "gpg2 -dq ~/.config/neomutt/gmail-pass.gpg"

account default : gmail
```

- [ ] **Step 3: Rechte setzen und Konfiguration prüfen**

msmtp verweigert den Dienst, wenn die Datei für andere lesbar ist.

```bash
chmod 600 ~/.msmtprc
mkdir -p ~/.cache
msmtp --pretend --account=gmail wafgo01@gmail.com </dev/null
```

Erwartet: eine Zusammenfassung des Kontos ohne Fehler.

- [ ] **Step 4: Testmail versenden**

```bash
printf 'From: wafgo01@gmail.com\nTo: wafgo01@gmail.com\nSubject: msmtp Test\n\nTest von msmtp.\n' \
  | msmtp --account=gmail wafgo01@gmail.com && echo "gesendet"
```

Erwartet: `gesendet`. Bei Fehlern zeigt `tail ~/.cache/msmtp.log` die Ursache.

- [ ] **Step 5: Zustellung prüfen**

```bash
sleep 20 && ~/.local/bin/mailsync >/dev/null 2>&1
notmuch search subject:"msmtp Test"
```

Erwartet: mindestens ein Treffer.

- [ ] **Step 6: git auf msmtp umstellen**

`git send-email` behandelt einen absoluten Pfad in `smtpserver` als
sendmail-kompatibles Programm; die übrigen `smtp*`-Einträge werden dann nicht
mehr ausgewertet und entfallen.

```bash
git config --global sendemail.smtpserver /usr/bin/msmtp
git config --global --unset sendemail.smtpserverport
git config --global --unset sendemail.smtpencryption
git config --global --unset sendemail.smtpuser
git config --global user.email wafgo01@gmail.com
git config --global sendemail.annotate yes
git config --global sendemail.confirm always
```

- [ ] **Step 7: Ergebnis prüfen**

```bash
git config --global --get-regexp 'sendemail|user\.'
```

Erwartet: `user.email=wafgo01@gmail.com` und
`sendemail.smtpserver=/usr/bin/msmtp`; keine `smtpserverport`-,
`smtpencryption`- oder `smtpuser`-Zeilen mehr.

Falls dienstliche Repositories weiterhin `wadim.mueller@cmblu.de` brauchen, wird
die Adresse dort lokal gesetzt:

```bash
git -C <pfad-zum-cmblu-repo> config user.email wadim.mueller@cmblu.de
```

- [ ] **Step 8: git send-email trocken testen**

```bash
cd /home/sefo/devel/git/linux-mainline
git send-email --dry-run --to=wafgo01@gmail.com --suppress-cc=all HEAD~1..HEAD
```

Erwartet: die Ausgabe zeigt `From: Wadim Mueller <wafgo01@gmail.com>` und
`Server: /usr/bin/msmtp`, ohne dass tatsächlich versendet wird.

---

### Task 9: Emacs-Grundkonfiguration für notmuch und Versand

**Files:**
- Create: `~/.emacs.d/lisp/mail-config.el`
- Modify: `~/.emacs.d/init.el`

**Interfaces:**
- Consumes: `emacs-notmuch` aus Task 1, `/usr/bin/msmtp` aus Task 8
- Produces: das Feature `mail-config`, das Kommando `M-x notmuch`, korrekt konfiguriertes `message-mode`. Task 10 erweitert dieselbe Datei um gespeicherte Suchen, Task 11 um piem.

- [ ] **Step 1: Ausgangszustand prüfen**

```bash
ls ~/.emacs.d/lisp/mail-config.el 2>/dev/null || echo "keine mail-config"
grep -n "mail-config" ~/.emacs.d/init.el || echo "nicht eingebunden"
emacs --batch --eval '(progn (require (quote notmuch)) (message "notmuch geladen"))' 2>&1 | tail -2
```

Erwartet: `keine mail-config`, `nicht eingebunden`; `notmuch geladen` erscheint,
da `emacs-notmuch` im site-lisp-Pfad liegt.

- [ ] **Step 2: `~/.emacs.d/lisp/mail-config.el` anlegen**

`message-send-mail-with-sendmail` übergibt die fertige Nachricht an msmtp — damit
läuft der Versand über denselben Pfad wie `git send-email`.
`message-sendmail-envelope-from` auf `header` sorgt dafür, dass msmtp das
richtige Konto wählt. `fill-column` 72 und abgeschaltetes `format=flowed` sind
für Kernel-Listen zwingend, weil Patches sonst beim Empfänger umgebrochen
ankommen.

```elisp
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

(global-set-key (kbd "C-c m") #'notmuch)

(provide 'mail-config)
;;; mail-config.el ends here
```

- [ ] **Step 3: Einbindungsstelle in `init.el` bestimmen**

Emacs verwaltet am Dateiende möglicherweise einen `custom-set-variables`-Block.
Die neuen Zeilen gehören **davor**, sonst überschreibt Emacs sie irgendwann.

```bash
grep -n "custom-set-variables\|custom-set-faces\|custom-file" ~/.emacs.d/init.el
```

- [ ] **Step 4: In `init.el` einbinden**

An der in Step 3 ermittelten Stelle einfügen — vor einem etwaigen
`custom-set-variables`, sonst ans Dateiende:

```elisp
;; Mail-Setup (notmuch, msmtp, piem)
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'mail-config)
```

- [ ] **Step 5: Laden im Batch-Modus testen**

```bash
emacs --batch -l ~/.emacs.d/init.el --eval '(message "init ok: %s" (featurep (quote mail-config)))' 2>&1 | tail -5
```

Erwartet: `init ok: t`, keine Fehler-Backtraces.

- [ ] **Step 6: Konfigurationswerte verifizieren**

```bash
emacs --batch -l ~/.emacs.d/init.el --eval \
  '(message "sendmail=%s fcc=%s from=%s" sendmail-program notmuch-fcc-dirs user-mail-address)' 2>&1 | tail -2
```

Erwartet: `sendmail=/usr/bin/msmtp fcc=gmail/Sent from=wafgo01@gmail.com`

- [ ] **Step 7: Interaktiv prüfen**

Emacs starten, `C-c m` drücken. Erwartet: der notmuch-Startbildschirm erscheint
und zeigt eine Nachrichtenzahl größer 0.

- [ ] **Step 8: Testmail aus Emacs senden**

In Emacs `C-c m`, dann `m` für eine neue Nachricht. An `wafgo01@gmail.com`
adressieren, Betreff `Emacs Test`, kurzer Text, dann `C-c C-c`.

```bash
sleep 30 && ~/.local/bin/mailsync >/dev/null 2>&1 && notmuch search subject:"Emacs Test"
```

Erwartet: mindestens ein Treffer.

- [ ] **Step 9: Prüfen, dass die Nachricht im Sent-Ordner liegt**

Das belegt, dass `notmuch-fcc-dirs` greift und mbsync die Kopie zu Gmail
hochgeschoben hat.

```bash
notmuch search --output=files subject:"Emacs Test" | grep "gmail/Sent" \
  && echo "OK: liegt in Sent" || echo "FEHLER: nicht in Sent"
```

Erwartet: `OK: liegt in Sent`

- [ ] **Step 10: Prüfen, dass die Nachricht als reiner Text verschickt wurde**

```bash
notmuch show --format=raw subject:"Emacs Test" | grep -i "^content-type"
```

Erwartet: `Content-Type: text/plain; charset=utf-8` — **ohne** `format=flowed`.
Steht dort `format=flowed`, darf kein Patch versendet werden, bevor das behoben
ist.

- [ ] **Step 11: Committen**

```bash
cd ~/.emacs.d
git add lisp/mail-config.el init.el
git commit -m "feat: notmuch als Mail-Client einrichten

Grundkonfiguration fuer notmuch-emacs: Identitaet, Versand ueber msmtp
und Kernel-taugliche Mail-Hygiene (text/plain, kein format=flowed,
72 Spalten).

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" \
  -- lisp/mail-config.el init.el
```

---

### Task 10: Gespeicherte Suchen als Sidebar-Ersatz

**Files:**
- Modify: `~/.emacs.d/lisp/mail-config.el`

**Interfaces:**
- Consumes: `mail-config` aus Task 9, die Tags aus Task 4
- Produces: `notmuch-saved-searches` mit zehn Einträgen

- [ ] **Step 1: Prüfen, dass die Abfragen Treffer liefern**

Bevor die Suchen in die Oberfläche wandern, muss feststehen, dass sie überhaupt
etwas finden — eine gespeicherte Suche mit konstant 0 Treffern ist ein Fehler.

```bash
for q in "tag:inbox" "tag:to-me" "tag:unread" "tag:iio" "tag:lore" "tag:patch" "tag:lkml" "tag:sent"; do
  printf '%-14s %s\n' "$q" "$(notmuch count $q)"
done
```

Erwartet: `inbox`, `unread`, `sent` und `lore` sind größer 0. `iio`, `lkml` und
`patch` dürfen 0 sein, falls noch keine Listen-Mail direkt eingegangen ist — die
lore-Treffer decken den IIO-Bedarf ab.

- [ ] **Step 2: Suchen in `mail-config.el` ergänzen**

Einfügen unmittelbar vor der Zeile `(global-set-key (kbd "C-c m") #'notmuch)`:

```elisp
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
        (:name "Entwuerfe"      :query "folder:gmail/Drafts"                  :key "d")
        (:name "Alles"          :query "*"                                    :key "a")))

(setq notmuch-saved-search-sort-function nil)
```

- [ ] **Step 3: Syntax prüfen**

```bash
emacs --batch -l ~/.emacs.d/init.el --eval \
  '(message "Suchen: %d" (length notmuch-saved-searches))' 2>&1 | tail -2
```

Erwartet: `Suchen: 10`

- [ ] **Step 4: Jede Abfrage auf Gültigkeit prüfen**

Eine syntaktisch falsche notmuch-Abfrage fällt sonst erst im laufenden Betrieb
auf.

```bash
emacs --batch -l ~/.emacs.d/init.el --eval \
  '(dolist (s notmuch-saved-searches)
     (let ((q (plist-get s :query)))
       (message "%-16s -> %s" (plist-get s :name)
                (string-trim (shell-command-to-string
                              (concat "notmuch count " (shell-quote-argument q)))))))' 2>&1 | tail -12
```

Erwartet: für jede Suche eine Zahl, keine Meldung wie `unbalanced parentheses`
oder `syntax error`.

- [ ] **Step 5: Interaktiv prüfen**

Emacs starten, `C-c m`. Erwartet: alle zehn Suchen erscheinen mit ihren
Tastenkürzeln; `i` springt in die Inbox.

- [ ] **Step 6: Committen**

```bash
cd ~/.emacs.d
git add lisp/mail-config.el
git commit -m "feat: gespeicherte notmuch-Suchen als Sidebar-Ersatz

Ersetzt die Ordneransicht aus neomutt durch gespeicherte Suchen fuer
Inbox, Ungelesenes, direkt adressierte Mail, IIO, Patches, LKML und
Gesendetes.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" \
  -- lisp/mail-config.el
```

---

### Task 11: piem für den Patch-Workflow

**Files:**
- Modify: `~/.emacs.d/lisp/mail-config.el`

**Interfaces:**
- Consumes: `mail-config` aus Task 9, `b4` aus Task 1, das Repo `/home/sefo/devel/git/linux-mainline`
- Produces: das Kommando `piem-dispatch` unter `C-c p`, aktiver `piem-notmuch-mode`

- [ ] **Step 1: Verfügbarkeit prüfen**

```bash
b4 --version
emacs --batch --eval '(progn (require (quote package)) (package-initialize)
  (message "piem: %s" (if (package-installed-p (quote piem)) "da" "fehlt")))' 2>&1 | tail -2
```

Erwartet: eine b4-Version und `piem: fehlt`.

- [ ] **Step 2: piem installieren**

```bash
emacs --batch --eval '(progn (require (quote package))
  (add-to-list (quote package-archives) (quote ("melpa" . "https://melpa.org/packages/")))
  (package-initialize) (package-refresh-contents)
  (package-install (quote piem)))' 2>&1 | tail -5
```

- [ ] **Step 3: Installation verifizieren**

```bash
emacs --batch --eval '(progn (require (quote package)) (package-initialize)
  (message "piem: %s" (if (package-installed-p (quote piem)) "da" "fehlt")))' 2>&1 | tail -2
```

Erwartet: `piem: da`

- [ ] **Step 4: piem in `mail-config.el` konfigurieren**

Einfügen vor der Zeile `(provide 'mail-config)`. `piem-inboxes` verknüpft die
Mailingliste mit dem lokalen Repository — daran erkennt piem, wohin ein Patch
angewendet werden soll.

```elisp
;;; piem — Patch-Serien aus Mails ins Repository holen

(require 'piem)
(require 'piem-notmuch)
(require 'piem-b4)

(setq piem-inboxes
      '(("linux-iio"
         :url "https://lore.kernel.org/linux-iio/"
         :address "linux-iio@vger.kernel.org"
         :coderepo "/home/sefo/devel/git/linux-mainline/")
        ("linux-kernel"
         :url "https://lore.kernel.org/linux-kernel/"
         :address "linux-kernel@vger.kernel.org"
         :coderepo "/home/sefo/devel/git/linux-mainline/")))

(setq piem-b4-b4-executable "b4"
      piem-default-branch-function #'piem-name-branch-who-what-v)

(piem-notmuch-mode 1)

(global-set-key (kbd "C-c p") #'piem-dispatch)
```

- [ ] **Step 5: Laden prüfen**

```bash
emacs --batch -l ~/.emacs.d/init.el --eval \
  '(message "piem: %s / inboxes: %d / notmuch-mode: %s"
            (featurep (quote piem)) (length piem-inboxes) piem-notmuch-mode)' 2>&1 | tail -2
```

Erwartet: `piem: t / inboxes: 2 / notmuch-mode: t`

- [ ] **Step 6: b4 eigenständig gegen lore testen**

Damit steht fest, dass der Netzwerkpfad funktioniert, bevor die
Emacs-Integration verdächtigt wird.

```bash
cd /tmp
MID=$(notmuch search --output=messages --limit=1 'tag:lore and subject:PATCH' | sed 's/^id://')
echo "Message-ID: $MID"
b4 mbox -o /tmp "$MID" && ls -la /tmp/*.mbx
```

Erwartet: eine heruntergeladene `.mbx`-Datei. Liefert die Suche keine
Nachrichten-ID, stattdessen `tag:patch` ohne `tag:lore` verwenden.

- [ ] **Step 7: Interaktiv testen**

Zuerst sicherstellen, dass der Kernel-Tree sauber ist — piem wendet Patches im
Arbeitsverzeichnis an:

```bash
cd /home/sefo/devel/git/linux-mainline && git status --short && git branch --show-current
```

Dann in Emacs `C-c m`, die gespeicherte Suche *IIO* öffnen, eine Nachricht mit
`[PATCH` im Betreff aufrufen und `C-c p` drücken.

Erwartet: das piem-Menü erscheint und bietet `b4-am` an. Der Aufruf lädt die
Serie samt der als Antwort eingegangenen `Reviewed-by:`-Tags und fragt nach dem
Ziel; als Vorgabe erscheint `/home/sefo/devel/git/linux-mainline/`.

- [ ] **Step 8: Committen**

```bash
cd ~/.emacs.d
git add lisp/mail-config.el
git commit -m "feat: piem fuer den Kernel-Patch-Workflow einbinden

Verknuepft linux-iio und linux-kernel mit dem lokalen Kernel-Tree, damit
Patch-Serien per b4 direkt aus einer Mail heraus angewendet werden
koennen.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" \
  -- lisp/mail-config.el
```

---

### Task 12: Konfigurationen sichern und Abnahme

**Files:**
- Create: `~/.emacs.d/docs/superpowers/mail-setup/` mit Kopien aller Konfigurationsdateien und einer `README.md`

**Interfaces:**
- Consumes: sämtliche Konfigurationsdateien aus den Tasks 2–8

- [ ] **Step 1: Alle Abnahmekriterien der Spec durchgehen**

```bash
echo "1. mbsync:"     && mbsync gmail && echo "   OK"
echo "2. notmuch:"    && notmuch count
echo "3. Sent:"       && notmuch count tag:sent
echo "4. send-email:" && (cd /home/sefo/devel/git/linux-mainline && \
     git send-email --dry-run --to=wafgo01@gmail.com --suppress-cc=all HEAD~1..HEAD >/dev/null && echo "   OK")
echo "5. lore:"       && notmuch count tag:lore
echo "6. Timer:"      && systemctl --user is-active mailsync.timer
```

Erwartet: durchgehend `OK` beziehungsweise Zahlen größer 0 und `active`.

- [ ] **Step 2: Konfigurationen ins Repo kopieren**

Das Passwort selbst wird nirgends kopiert — nur der Befehl, der es entschlüsselt.

```bash
D=~/.emacs.d/docs/superpowers/mail-setup
mkdir -p "$D"
cp ~/.mbsyncrc                             "$D/mbsyncrc"
cp ~/.msmtprc                              "$D/msmtprc"
cp ~/.notmuch-config                       "$D/notmuch-config"
cp ~/Mail/.notmuch/hooks/post-new          "$D/notmuch-hook-post-new"
cp ~/.local/bin/mailsync                   "$D/mailsync"
cp ~/.config/systemd/user/mailsync.service "$D/mailsync.service"
cp ~/.config/systemd/user/mailsync.timer   "$D/mailsync.timer"
```

- [ ] **Step 3: Prüfen, dass keine Geheimnisse mitkopiert wurden**

```bash
grep -rniE 'BEGIN PGP|^[[:space:]]*password[[:space:]]' ~/.emacs.d/docs/superpowers/mail-setup/ \
  && echo "ACHTUNG: Geheimnis gefunden" || echo "sauber"
```

Erwartet: `sauber`. Die Dateien dürfen nur `passwordeval`- beziehungsweise
`PassCmd`-Zeilen enthalten, die auf `gpg2 -dq` verweisen.

- [ ] **Step 4: README schreiben**

Nach `~/.emacs.d/docs/superpowers/mail-setup/README.md`:

```markdown
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
```

- [ ] **Step 5: Committen**

```bash
cd ~/.emacs.d
git add docs/superpowers/mail-setup/
git commit -m "docs: Mail-Konfiguration im Repo sichern

Kopien von mbsyncrc, msmtprc, notmuch-config, Tagging-Hook, Sync-Skript
und systemd-Units samt README, damit sich das Setup reproduzieren laesst.
Das Passwort bleibt ausschliesslich in gmail-pass.gpg.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" \
  -- docs/superpowers/mail-setup/
```

- [ ] **Step 6: neomutt-Rückfallebene bestätigen**

```bash
ls -la ~/.config/neomutt/neomuttrc ~/.config/neomutt/gmail-pass.gpg
neomutt -v | head -1
```

Erwartet: beide Dateien unverändert vorhanden, neomutt startbar. Es greift
weiterhin direkt per IMAP zu und wird vom lokalen Maildir nicht berührt.

---

## Bekannte Stolpersteine

**Gmail verlangt ein App-Passwort.** Das reguläre Kontopasswort funktioniert
nicht. Das bestehende in `gmail-pass.gpg` stammt aus dem neomutt-Setup und ist
gültig — wird es von Google widerrufen, muss ein neues erzeugt und die
GPG-Datei ersetzt werden.

**Der gpg-agent muss das Passwort zwischenspeichern.** Sonst blockiert der
systemd-Timer bei jedem Lauf mit einem Passphrase-Prompt, den niemand sieht.
Task 7, Step 2 beschreibt die nötigen `gpg-agent.conf`-Einträge.

**Löschen wirkt sich auf Gmail aus.** `Expunge Both` in `.mbsyncrc` bedeutet:
was lokal als gelöscht markiert wird, verschwindet beim nächsten Sync auch bei
Gmail. Das ist gewollt, sollte aber bewusst sein.

**notmuch löscht nichts.** Ein `notmuch tag +deleted` entfernt nur aus der
Ansicht. Tatsächliches Löschen erfordert das Verschieben nach
`~/Mail/gmail/Trash`.

**`format=flowed` bricht Patches.** Task 9, Step 10 prüft das explizit. Erscheint
`format=flowed` im `Content-Type`, darf kein Patch versendet werden, bevor das
behoben ist.
