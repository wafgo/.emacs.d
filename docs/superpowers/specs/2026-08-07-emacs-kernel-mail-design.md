# Emacs als Mail-Client für Linux-Kernel-Entwicklung

Datum: 2026-08-07
Status: Design freigegeben

## Ziel

neomutt vollständig durch einen Emacs-basierten Mail-Workflow ersetzen: Lesen,
Suchen, Threads verfolgen, Antworten und Patches auf die Linux-Kernel-Mailinglisten
versenden.

## Ausgangslage

- Emacs 30.2, Paketverwaltung über `package.el` + `use-package` (`~/.emacs.d/init.el`)
- Fedora 41 Workstation
- `notmuch-0.38.3` installiert, aber unkonfiguriert
- neomutt greift direkt per IMAP auf Gmail zu, kein lokaler Maildir
- Gmail-App-Passwort liegt GPG-verschlüsselt in `~/.config/neomutt/gmail-pass.gpg`
- `git send-email` ist bereits konfiguriert (Gmail-SMTP, Port 587, TLS)
- Kein `isync`, kein `msmtp`, kein `b4` installiert

## Entscheidungen

| Frage | Entscheidung |
|---|---|
| Umfang | Kompletter Ersatz für neomutt |
| Mail-Quellen | Gmail-Postfach **und** lore.kernel.org über `lei` |
| Credentials | Bestehendes `~/.config/neomutt/gmail-pass.gpg` weiterverwenden |
| Absenderadresse | `wafgo01@gmail.com` |
| Patch-Workflow | `piem`-Integration **und** weiterhin `git send-email` aus der Shell |
| Interessenschwerpunkt | IIO-Subsystem (`linux-iio`, `drivers/iio/`) |
| Client | notmuch + mbsync + msmtp + lei + piem |

### Warum notmuch und nicht mu4e oder Gnus

notmuch ist bereits installiert, `lei` gehört zum selben Ökosystem und deckt die
lore.kernel.org-Anbindung ab. Die suchbasierte Bedienung skaliert mit dem
Mailaufkommen der Kernel-Listen, und der Workflow ist unter Kernel-Entwicklern
etabliert (`b4` baut darauf auf).

mu4e wurde verworfen, weil `mu` zusätzlich installiert werden müsste, die
lore-Anbindung schwächer ist und die Emacs-Paketversion exakt zur `mu`-Binary
passen muss — das bricht bei Distributions-Updates regelmäßig.

Gnus wurde verworfen, weil der direkte IMAP-Zugriff bei großen Listen langsam
ist, offline nicht nutzbar und keine lore-Integration bietet.

## Architektur

```
Gmail IMAP  ──mbsync(isync)──►  ~/Mail/gmail/{INBOX,Sent,Drafts,Trash}
lore.kernel.org ──lei q──────►  ~/Mail/lei/<saved-search>/
                                        │
                                   notmuch index (~/Mail/.notmuch)
                                        │
                              notmuch-emacs (Emacs 30.2)
                                        │
                        ┌───────────────┴───────────────┐
                   message-mode                      piem
                   → msmtp → Gmail SMTP           → b4 / git am → linux-mainline
                   + Fcc in ~/Mail/gmail/Sent
                     (mbsync pusht hoch)
```

Grundprinzipien:

- **Ein Maildir-Root** `~/Mail`, ein notmuch-Index darüber. Gmail-Mails und
  lore-Ergebnisse liegen nebeneinander; notmuch fädelt zusammengehörige
  Nachrichten quellenübergreifend zu einem Thread zusammen.
- **mbsync bidirektional** für INBOX, Sent, Drafts, Trash. Gmail „All Mail" wird
  bewusst nicht synchronisiert — das erzeugt Duplikate und mehrere Gigabyte.
- **Versand über msmtp**, nicht über Emacs' `smtpmail`. Damit nutzen Emacs und
  `git send-email` denselben Sendepfad und dieselbe Credential-Quelle.
- **Sync über einen systemd-User-Timer**, nicht über einen Emacs-Timer. Der Sync
  läuft dann unabhängig davon, ob Emacs gerade neu startet.

## Komponenten

| Komponente | Datei | Zweck |
|---|---|---|
| isync | `~/.mbsyncrc` | Gmail ↔ `~/Mail/gmail/`; Ordner INBOX, Sent, Drafts, Trash |
| msmtp | `~/.msmtprc` | SMTP-Versand; `passwordeval` ruft `gpg2 -dq ~/.config/neomutt/gmail-pass.gpg` |
| notmuch | `~/.notmuch-config` | `database.path=~/Mail`, `user.primary_email=wafgo01@gmail.com` |
| notmuch-Hook | `~/Mail/.notmuch/hooks/post-new` | Auto-Tagging: `lkml`, `patch`, `to-me`, `inbox` |
| lei | — | `lei q -o ~/Mail/lei/<name>` für lore-Queries, aufgerufen aus dem Sync-Skript |

### Initiale lore-Queries

Interessenschwerpunkt ist das IIO-Subsystem (Industrial I/O). Eingerichtet wird
eine gespeicherte lei-Suche:

- `iio` → `~/Mail/lei/iio`, Query:
  `(l:linux-iio.vger.kernel.org OR dfn:drivers/iio/** OR dfn:include/linux/iio/**) AND rt:3.months.ago..`

Die Suche deckt sowohl die Mailingliste `linux-iio` als auch Patches ab, die
Dateien unterhalb von `drivers/iio/` oder `include/linux/iio/` berühren und über
andere Listen laufen. Das Zeitfenster von drei Monaten begrenzt den initialen
Download; `lei up` holt anschließend nur Neues nach.

Weitere Queries lassen sich später mit demselben Muster ergänzen — jede
gespeicherte Suche bekommt ein eigenes Ausgabeverzeichnis unter `~/Mail/lei/`
und wird von `lei up --all` mitaktualisiert.
| Sync-Skript | `~/.local/bin/mailsync` | `mbsync -a` → `lei up --all` → `notmuch new` |
| systemd | `~/.config/systemd/user/mailsync.{service,timer}` | Ausführung alle 5 Minuten |
| Emacs | `~/.emacs.d/lisp/mail-config.el` | notmuch, message-mode, piem; per `require` aus `init.el` |
| git | `~/.gitconfig` | `sendemail.smtpserver` auf `/usr/bin/msmtp` umstellen; `user.email` auf `wafgo01@gmail.com` setzen |

### Änderung an der Git-Konfiguration

Aktuell spricht `git send-email` den Gmail-SMTP-Server direkt an und `user.email`
steht auf `wadim.mueller@cmblu.de`, während als SMTP-Benutzer
`wafgo01@gmail.com` hinterlegt ist. Absender und Sendekonto fallen damit
auseinander, was bei Kernel-Patches zu einem `From:`/`Sender:`-Mismatch führt.

Deshalb wird `sendemail.smtpserver` auf `/usr/bin/msmtp` gesetzt — `git
send-email` behandelt einen absoluten Pfad als sendmail-kompatibles Programm und
übergibt die Mail dorthin. Die bisherigen `sendemail.smtp*`-Einträge entfallen.
`user.email` wird global auf `wafgo01@gmail.com` gesetzt, damit `Signed-off-by:`
und `From:` zur Absenderadresse passen. Falls für die Arbeit bei cmblu weiterhin
die dortige Adresse gebraucht wird, geschieht das über eine repository-lokale
`user.email` in den betreffenden Arbeitsrepositories.

### Emacs-Konfiguration

- `notmuch` stammt aus dem Fedora-Paket, nicht aus MELPA. Aus MELPA kommen
  `piem`, `piem-notmuch` und `piem-b4`.
- Mail-Hygiene für Kernel-Listen in `message-mode`: `text/plain` erzwungen,
  `format=flowed` deaktiviert, `fill-column` auf 72, kein
  Quoted-Printable-Umbruch von Patches, `message-send-mail-function` auf
  `message-send-mail-with-sendmail` mit msmtp als `sendmail-program`.
- Gespeicherte Suchen in `notmuch-hello` ersetzen die neomutt-Sidebar:
  *Inbox*, *An mich*, *LKML ungelesen*, *IIO*, *Patches*, *Gesendet*.
- Standard-Emacs-Tastenbelegung, keine Evil-Bindings.
- `piem`: `piem-b4-am` auf einer Patch-Mail holt über `b4` die vollständige
  Patch-Serie von lore — inklusive der als Antwort eingegangenen
  `Reviewed-by:`/`Acked-by:`-Tags — und wendet sie in
  `/home/sefo/devel/git/linux-mainline` an.

## Fehlerbehandlung und Migration

- neomutt bleibt unangetastet und funktionsfähig; es dient als Rückfallebene
  während der Umstellung.
- Der erste `mbsync`-Lauf erfolgt manuell im Vordergrund, weil er bei großem
  Postfach lange dauern kann. Der systemd-Timer wird erst danach aktiviert.
- `mailsync` protokolliert Fehler ins Journal, abrufbar über
  `journalctl --user -u mailsync`.

## Abnahmekriterien

1. `mbsync -a` legt Mail unter `~/Mail/gmail/` ab und läuft ohne Fehler durch.
2. `notmuch count` liefert einen Wert größer null.
3. Eine aus Emacs an die eigene Adresse gesendete Testmail kommt an und
   erscheint nach dem nächsten Sync unter `~/Mail/gmail/Sent`.
4. `git send-email --dry-run` einer Testcommit-Serie läuft über msmtp ohne
   Fehler.
5. `piem-b4-am` wendet eine Patch-Serie von lore im Kernel-Tree an.
6. `notmuch-hello` zeigt die gespeicherten Suchen mit plausiblen Trefferzahlen.
7. `lei up --all` aktualisiert die IIO-Suche und die neuen Nachrichten tauchen
   nach `notmuch new` unter der gespeicherten Suche *IIO* auf.
