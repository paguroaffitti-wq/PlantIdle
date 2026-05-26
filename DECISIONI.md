# 📋 LOG DELLE DECISIONI IMPORTANTI - PlantIdle

> **A cosa serve:** tenere traccia delle decisioni significative e del *perché* sono state prese. Quando tra 6 mesi ti chiederai "perché avevamo scelto X invece di Y?", la risposta è qui.

---

## DECISIONI PRESE

### #001 - Game engine: Godot 4.6 Standard
- **Data:** Maggio 2026
- **Decisione:** Godot 4.6 Standard con GDScript
- **Alternative considerate:** Unity, Flutter+Flame, GameMaker, Defold, no-code (Construct 3, GDevelop)
- **Motivazione:** Gratuito, open source, zero royalty, ottimo per 2D mobile, GDScript simile a Python. Per un cozy idle 2D è lo strumento ideale. Unity sarebbe overkill.
- **Nota:** inizialmente documentato come Godot 4.3, corretto a 4.6 dopo aver verificato la versione effettiva in uso.

### #002 - Target piattaforma: Android prima, iOS dopo
- **Data:** Maggio 2026
- **Decisione:** Android first, iOS solo se Android funziona
- **Alternative considerate:** iOS prima, entrambi insieme
- **Motivazione:** Android = 25$ una tantum vs iOS = 99$/anno. Sviluppatore ha Mac quindi iOS resta possibile, ma prima validiamo l'idea su Android.

### #003 - Stile visivo v1: 2D piatto cottagecore
- **Data:** Maggio 2026
- **Decisione:** v1.0 = 2D piatto vista frontale stile Window Garden. Isometrico rimandato a v2.0.
- **Alternative considerate:** Isometrico fin dall'inizio (stile Animal Crossing Pocket Camp)
- **Motivazione:** Isometrico = 10-14 mesi part-time. 2D piatto = 6-8 mesi. Validare prima con qualcosa di pubblicabile.

### #004 - Concept piante: appartamento realistico + kawaii
- **Data:** Maggio 2026
- **Decisione:** Piante d'appartamento realistiche (pachira, monstera, pothos, sansevieria...) con qualche pianta kawaii speciale sbloccabile
- **Motivazione:** Le piante d'appartamento sono in boom culturale dal 2020. Nicchia con domanda reale e poca concorrenza nel mobile gaming.

### #005 - Esperienza target: rilassante + collezionistica
- **Data:** Maggio 2026
- **Decisione:** Focus su rilassante e collezionistico. Sociale "lite" rimandato a v2.0.
- **Motivazione:** Il sociale richiede backend, server, moderazione. Per v1 si valuta una versione "codice condivisibile" senza server.

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
- **Motivazione:** GitHub pubblico permette a Claude di leggere file via URL raw. Struttura con `game/` separata dalla documentazione mantiene tutto pulito.

### #008 - Tool Git: GitHub Desktop per uso quotidiano
- **Data:** Maggio 2026
- **Decisione:** GitHub Desktop per commit/push quotidiani, Git Bash solo per operazioni avanzate
- **Motivazione:** GitHub Desktop è più semplice e visivo.

### #009 - Architettura piante: componenti autonomi con segnali
- **Data:** Maggio 2026 (M1 Step 1)
- **Decisione:** Ogni pianta è una scena/script autonomo (`pianta.tscn` + `pianta.gd`) con `class_name Pianta`. Non conosce il giardino: comunica via segnali (`raccolta_effettuata`, `stato_cambiato`). Il giardino ascolta e gestisce stato globale e salvataggio.
- **Alternative considerate:** Tenere tutto in main.gd con array di stati piante senza scena separata
- **Motivazione:** Componente riutilizzabile, ogni pianta gestisce la sua UI inline (necessario con N piante: pulsanti globali sarebbero ambigui). I segnali permettono di agganciare nuovi sistemi (missioni, achievement) senza toccare il codice della pianta.
- **Conseguenze:** Quando in M3 arrivano gli sprite, si tocca solo `pianta.gd` e `pianta.tscn`. Il giardino non cambia.

### #010 - Salvataggio versionato, vecchi save scartati durante sviluppo
- **Data:** Maggio 2026 (M1 Step 1, aggiornato in Step 2 e Step 3)
- **Decisione:** Il save JSON include sempre un campo `versione`. Al caricamento, se la versione non corrisponde all'attuale, il save viene ignorato silenziosamente e il gioco parte da zero.
- **Versioni:** v1 (Step 1) → v2 (Step 2, aggiunto id_pianta per slot) → v3 (Step 3, aggiunto piante_sbloccate e numero_vasi)
- **Alternative considerate:** Migrazione automatica tra versioni
- **Motivazione:** Durante sviluppo l'unico tester è lo sviluppatore. La migrazione va scritta quando ci sono utenti reali (M6+). Il campo `versione` è già pronto per future migrazioni.

### #011 - Database piante: risorse Godot .tres invece di dizionario hardcoded
- **Data:** Maggio 2026 (M1 Step 2)
- **Decisione:** Ogni tipo di pianta è un file `.tres` (istanza di `DatiPianta extends Resource`) in `data/piante/`. Il database è un dizionario di `preload()` in `progresso_giocatore.gd`.
- **Alternative considerate:** Dizionario hardcoded in un file `.gd` (es. `dati_piante.gd`)
- **Motivazione:** I `.tres` sono editabili visualmente nell'inspector di Godot senza toccare codice. Bilanciare una pianta = aprire il `.tres`, cambiare un numero, salvare. Quando in M3 arrivano gli sprite, si trascina la texture nel campo apposito. Per 3-15 piante è la soluzione ideale. Il dizionario hardcoded avrebbe senso solo per dati che cambiano molto frequentemente o che vengono generati a runtime.
- **Come aggiungere una pianta in futuro:** tasto destro in FileSystem → New Resource → DatiPianta → compila → salva in `data/piante/` → aggiungi a `TUTTI_I_DATI` in `progresso_giocatore.gd`.

### #012 - Stato globale: singleton ProgressoGiocatore (Autoload)
- **Data:** Maggio 2026 (M1 Step 3)
- **Decisione:** Tutto lo stato persistente del giocatore (semi, piante sbloccate, vasi, contenuto slot) vive in un singleton registrato come Autoload in `project.godot`. Il giardino e lo shop sono "viste" che leggono/scrivono il singleton.
- **Alternative considerate:** Stato nel giardino (main.gd), passato allo shop tramite SceneTree o file temporaneo
- **Motivazione:** Con due scene separate (giardino e shop) serve uno stato condiviso. Il singleton è il pattern standard di Godot per questo caso. Permette a qualsiasi scena futura (missioni, achievement, statistiche) di leggere lo stato senza accoppiamenti diretti.
- **Conseguenze:** `main.gd` diventa una "vista": al `_ready()` legge `ProgressoGiocatore.slot_piante` e costruisce i nodi. Quando torna dallo shop il `_ready()` viene rieseguito e il giardino si ricostruisce automaticamente dallo stato aggiornato.

### #013 - Shop: scena separata invece di pannello a scomparsa
- **Data:** Maggio 2026 (M1 Step 3)
- **Decisione:** Lo shop è una scena indipendente (`shop.tscn`) raggiunta con `change_scene_to_file()`. Il ritorno al giardino usa lo stesso meccanismo.
- **Alternative considerate:** Pannello a scomparsa (overlay) nella scena giardino
- **Motivazione:** Scena separata = più spazio per la UI dello shop (scroll lista piante, sezioni distinte). In M2 quando lo shop crescerà (categorie, filtri, piante speciali) avrà già lo spazio per farlo. Il pannello overlay avrebbe richiesto di stare attenti a non sovrapporre elementi del giardino.
- **Conseguenza tecnica:** Prima di `change_scene_to_file()` il giardino chiama `ProgressoGiocatore.salva()` per sicurezza. Il singleton persiste tra scene, quindi lo stato non va da nessuna parte.

### #014 - Layout giardino: GridContainer 2 colonne con ScrollContainer
- **Data:** Maggio 2026 (M1 Step 4)
- **Decisione:** Il contenitore delle piante è un `GridContainer` (2 colonne fisse) dentro un `ScrollContainer`. Le piante hanno larghezza 220px (due per riga su 480px viewport).
- **Alternative considerate:** A) HBoxContainer orizzontale con rimpicciolimento dinamico. B) Stanze separate (giardino + serra). C) GridContainer 2 colonne (scelta).
- **Motivazione:** A) illeggibile oltre 3 piante. B) troppo complessa per M1, rimandato a M2 se necessario. C) è il pattern usato da Window Garden e dalla maggior parte dei mobile idle: leggibile, scalabile da 1 a 6 slot, scroll verticale disponibile se necessario.
- **Conseguenza:** Con N piante dispari l'ultima riga ha una pianta centrata sola — comportamento standard dei GridContainer, accettabile esteticamente.

### #015 - Estetica M1: palette cottagecore + tema Godot globale
- **Data:** Maggio 2026 (M1 Step 4)
- **Decisione:** Palette di 6 colori definita (crema, beige, salvia, foresta, terracotta, testo scuro). Implementata come `Theme` Godot in `assets/theme/theme.tres` con variazioni `Vaso` e `VasoVuoto`. Registrato come tema globale in `project.godot`.
- **Motivazione:** Tema globale = cambi un file e si propaga ovunque (giardino, shop, popup). Le variazioni di tema permettono Panel con stili diversi senza duplicare la logica. I placeholder `ColorRect` imitano già l'estetica finale: in M3 basterà swappare le texture, il layout non cambia.

### #016 - Stadi visivi pianta: 3 stadi discreti + animazione pop
- **Data:** Maggio 2026 (M1 Step 4)
- **Decisione:** La crescita non è continua ma suddivisa in 3 stadi visivi (germoglio 0-33%, giovane 33-66%, quasi maturo 66-100%) + stadio maturo con decorazione gialla. Al raggiungimento della maturità: animazione "pop" via Tween (scala 1.0 → 1.25 → 1.0). Al raccolto: label "+N 🌱" che fluttua verso l'alto e sparisce.
- **Motivazione:** Stadi discreti = chiari a colpo d'occhio, facili da sostituire con sprite in M3 (uno sprite per stadio). L'animazione pop è feedback immediato che rende la raccolta soddisfacente senza audio (audio rimandato a M2).

---

## TEMPLATE PER NUOVE DECISIONI

### #XXX - Titolo breve
- **Data:**
- **Decisione:**
- **Alternative considerate:**
- **Motivazione:**
- **Conseguenze attese:**

---

*Ultimo aggiornamento: Maggio 2026 — Milestone 1 completata*
