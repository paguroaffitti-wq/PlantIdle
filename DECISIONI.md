# 📋 LOG DELLE DECISIONI IMPORTANTI - PlantIdle

> **A cosa serve:** tenere traccia delle decisioni significative e del *perché* sono state prese. Quando tra 6 mesi ti chiederai "perché avevamo scelto X invece di Y?", la risposta è qui.

---

## DECISIONI PRESE

### #001 - Game engine: Godot 4.3 Standard
- **Data:** Maggio 2026
- **Decisione:** Godot 4.3 Standard con GDScript
- **Alternative considerate:** Unity, Flutter+Flame, GameMaker, Defold, no-code (Construct 3, GDevelop)
- **Motivazione:** Gratuito, open source, zero royalty, ottimo per 2D mobile, GDScript simile a Python (più veloce da scrivere). Per un cozy idle 2D è lo strumento ideale. Unity sarebbe overkill.

### #002 - Target piattaforma: Android prima, iOS dopo
- **Data:** Maggio 2026
- **Decisione:** Android first, iOS solo se Android funziona
- **Alternative considerate:** iOS prima, entrambi insieme
- **Motivazione:** Android = 25$ una tantum vs iOS = 99$/anno. Sviluppatore ha Mac quindi iOS resta possibile, ma prima validiamo l'idea su Android.

### #003 - Stile visivo v1: 2D piatto cottagecore
- **Data:** Maggio 2026
- **Decisione:** v1.0 = 2D piatto vista frontale stile Window Garden. Isometrico rimandato a v2.0.
- **Alternative considerate:** Isometrico fin dall'inizio (stile Animal Crossing Pocket Camp)
- **Motivazione:** Isometrico = 10-14 mesi part-time. 2D piatto = 6-8 mesi. Validare prima con qualcosa di pubblicabile. Se il gioco ha successo, v2.0 isometrica con le entrate generate.

### #004 - Concept piante: appartamento realistico + kawaii
- **Data:** Maggio 2026
- **Decisione:** Piante d'appartamento realistiche (pachira, monstera, pothos, sansevieria...) con qualche pianta kawaii speciale sbloccabile
- **Motivazione:** Le piante d'appartamento sono in boom culturale dal 2020. Nicchia con domanda reale e poca concorrenza nel mobile gaming. Il kawaii aggiunge varietà e attrae pubblico più giovane.

### #005 - Esperienza target: rilassante + collezionistica
- **Data:** Maggio 2026
- **Decisione:** Focus su rilassante e collezionistico. Sociale "lite" rimandato a v2.0.
- **Motivazione:** Il sociale richiede backend, server, moderazione = 6+ mesi di lavoro extra e costi mensili. Per v1 si valuta una versione "codice condivisibile" senza server.

### #006 - Stack AI: Claude + ChatGPT
- **Data:** Maggio 2026
- **Decisione:** Claude per codice/architettura/pianificazione, ChatGPT/DALL-E per asset visivi
- **Motivazione:** Sviluppatore ha già accesso a entrambi. Divisione chiara che sfrutta i punti di forza di ciascuno.

### #007 - Repository: GitHub pubblico con struttura documentata
- **Data:** Maggio 2026
- **Decisione:** GitHub pubblico con HANDOFF + CODEMAP + DECISIONI come documenti di progetto nella root
- **Struttura scelta:**
  ```
  PlantIdle/          ← root repo
  ├── .gitignore
  ├── HANDOFF.md
  ├── CODEMAP.md
  ├── DECISIONI.md
  ├── README.md
  └── game/           ← progetto Godot
  ```
- **Motivazione:** GitHub pubblico permette a Claude di leggere file via URL raw. Struttura con `game/` separata dalla documentazione mantiene tutto pulito. `.gitignore` nella root ignora `.godot/` ovunque.

### #008 - Tool Git: GitHub Desktop per uso quotidiano
- **Data:** Maggio 2026
- **Decisione:** GitHub Desktop per commit/push quotidiani, Git Bash solo per operazioni avanzate
- **Motivazione:** GitHub Desktop è più semplice e visivo. Git Bash resta disponibile per operazioni non supportate da Desktop (es. git rm --cached).

### #009 - Architettura piante: componenti autonomi con segnali
- **Data:** Maggio 2026
- **Decisione:** Ogni pianta è una scena/script autonomo (`pianta.tscn` + `pianta.gd`). 
  Non conosce il giardino: comunica via segnali (`raccolta_effettuata`, `stato_cambiato`). 
  Il giardino (`main.gd`) ascolta e gestisce stato globale e salvataggio.
- **Alternative considerate:** Tenere tutto in main.gd con array di stati piante (no scena pianta separata)
- **Motivazione:** Modulo riutilizzabile, ogni pianta gestisce la sua UI inline (necessario con N piante: 
  pulsanti globali sarebbero ambigui). I segnali permettono di agganciare nuovi sistemi (missioni, 
  statistiche, achievement) senza toccare il codice della pianta.

### #010 - Salvataggio: nuovo formato versionato, vecchio M0 scartato
- **Data:** Maggio 2026
- **Decisione:** Nuovo JSON con campo `versione: 1` e array `piante`. I save M0 (senza campo versione) 
  vengono ignorati silenziosamente al primo avvio.
- **Alternative considerate:** Migrazione automatica del save M0 a M1
- **Motivazione:** In M1 sono io l'unico tester, non vale la pena scrivere codice di migrazione. 
  Il campo `versione` è già pronto per future migrazioni quando avremo utenti reali.


---



## TEMPLATE PER NUOVE DECISIONI

### #XXX - Titolo breve
- **Data:**
- **Decisione:**
- **Alternative considerate:**
- **Motivazione:**
- **Conseguenze attese:**

---

*Ultimo aggiornamento: Maggio 2026 — Milestone 0 completata*
