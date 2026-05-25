# 📂 CODEMAP - Indice File del Progetto

> **A cosa serve questo file:** è la mappa del progetto. Quando lavori con un'AI, condividi questo file e l'AI saprà esattamente quale file aprire per quale compito. Aggiornato a ogni milestone.
>
> **Convenzione URL:** sostituire `[REPO]` con l'URL base della repo GitHub (es. `https://raw.githubusercontent.com/tuonome/PiantaCrescente/main/`)

---

## 🎯 FILE CHIAVE (da consultare per primi)

| File | URL | Scopo |
|------|-----|-------|
| `HANDOFF.md` | `[REPO]/HANDOFF.md` | Stato e piano del progetto |
| `CODEMAP.md` | `[REPO]/CODEMAP.md` | Questo file - mappa del codice |
| `DECISIONI.md` | `[REPO]/DECISIONI.md` | Log decisioni importanti |

---

## ⚙️ CONFIGURAZIONE PROGETTO

| File | URL | Scopo | Stato |
|------|-----|-------|-------|
| `project.godot` | `[REPO]/project.godot` | Configurazione Godot 4.3 - risoluzione, orientamento, scena principale | ✅ Milestone 0 |
| `icon.svg` | `[REPO]/icon.svg` | Icona placeholder del progetto | ✅ Milestone 0 |

---

## 🎬 SCENE GODOT (file .tscn)

| File | URL | Scopo | Script collegato | Stato |
|------|-----|-------|------------------|-------|
| `main.tscn` | `[REPO]/main.tscn` | Scena principale, contiene UI e pianta singola | `scripts/main.gd` | ✅ Milestone 0 |

---

## 💻 SCRIPT GDSCRIPT (file .gd)

| File | URL | Scopo principale | Funzioni chiave | Stato |
|------|-----|------------------|-----------------|-------|
| `scripts/main.gd` | `[REPO]/scripts/main.gd` | Logica completa Milestone 0: pianta singola, annaffia, raccogli, salvataggio, crescita offline | `_ready()`, `_su_annaffia_premuto()`, `aggiungi_acqua()`, `salva_dati()`, `carica_dati()` | ✅ Milestone 0 |

---

## 🎨 ASSET

| Cartella | URL | Contenuto | Stato |
|----------|-----|-----------|-------|
| `assets/piante/` | `[REPO]/assets/piante/` | Illustrazioni piante (vari stadi) | 🔲 Milestone 3 |
| `assets/ui/` | `[REPO]/assets/ui/` | Elementi interfaccia (pulsanti, icone) | 🔲 Milestone 2-3 |
| `assets/audio/` | `[REPO]/assets/audio/` | Musica lofi e effetti sonori | 🔲 Milestone 2 |

---

## 📚 DOCUMENTAZIONE

| File | URL | Scopo |
|------|-----|-------|
| `docs/milestone_0_completata.md` | `[REPO]/docs/milestone_0_completata.md` | Riepilogo cosa è stato fatto in Milestone 0 |

---

## 🗺️ COME USARE QUESTO FILE CON L'AI

Quando inizi una nuova conversazione:

1. Condividi `HANDOFF.md` per il contesto generale del progetto
2. Condividi `CODEMAP.md` per far sapere all'AI cosa c'è dove
3. L'AI ti chiederà i file specifici di cui ha bisogno (es. *"per Milestone 1 Step 1 ho bisogno di vedere il contenuto di `scripts/main.gd`"*)
4. Tu condividi l'URL del file richiesto e l'AI lo legge

**Esempio di prompt iniziale efficace:**
> *"Ciao Claude, ti condivido l'HANDOFF e la CODEMAP del progetto. Sono pronto a partire con Milestone 1 Step 1. Dimmi quali file ti serve vedere e te li condivido."*

---

## 📝 CONVENZIONI DI NAMING

- **Snake_case** per file Godot (`main.tscn`, `pianta.gd`) - convenzione Godot standard
- **PascalCase** per nodi nelle scene (`PulsanteAnnaffia`, `BarraCrescita`) - convenzione Godot standard
- **snake_case** per variabili e funzioni in GDScript (`acqua_attuale`, `salva_dati()`)
- **SCREAMING_SNAKE_CASE** per costanti (`ACQUA_PER_TAP`, `FILE_SALVATAGGIO`)
- **Italiano** per nomi di variabili/funzioni di game logic (rende il codice leggibile a un eventuale collaboratore italiano)
- **Inglese** per termini tecnici di engine (`_ready`, `connect`, `pressed`, ecc.) - obbligatorio

---

**Ultimo aggiornamento:** Milestone 0 completata
