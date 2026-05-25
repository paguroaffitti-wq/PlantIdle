# 📂 CODEMAP - Indice File del Progetto PlantIdle

> **A cosa serve:** mappa completa di tutti i file del progetto. Condividila con Claude all'inizio di ogni chat — l'AI saprà quale file aprire per quale compito senza doverlo cercare.
>
> **URL base raw GitHub:**
> `https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/`
>
> **Come usare gli URL:** sostituisci `[BASE]` con l'URL base qui sopra.

---

## 🎯 DOCUMENTI DI PROGETTO (root repo)

| File | URL raw | Scopo |
|------|---------|-------|
| `HANDOFF.md` | `[BASE]HANDOFF.md` | Stato completo del progetto, piano, profilo sviluppatore |
| `CODEMAP.md` | `[BASE]CODEMAP.md` | Questo file — mappa di tutti i file |
| `DECISIONI.md` | `[BASE]DECISIONI.md` | Log decisioni importanti e motivazioni |
| `README.md` | `[BASE]README.md` | Presentazione pubblica del progetto su GitHub |
| `.gitignore` | `[BASE].gitignore` | File e cartelle ignorati da Git |

---

## ⚙️ CONFIGURAZIONE GODOT (game/)

| File | URL raw | Scopo | Stato |
|------|---------|-------|-------|
| `game/project.godot` | `[BASE]game/project.godot` | Config Godot: risoluzione 480x800, orientamento portrait, scena principale | ✅ M0 |
| `game/icon.svg` | `[BASE]game/icon.svg` | Icona placeholder del progetto | ✅ M0 |

---

## 🎬 SCENE GODOT (file .tscn)

| File | URL raw | Scopo | Script collegato | Stato |
|------|---------|-------|-----------------|-------|
| `game/main.tscn` | `[BASE]game/main.tscn` | Scena giardino: sfondo, label semi globale, HBoxContainer per N piante | `game/scripts/main.gd` | ✅ M1.1 |
| `game/scenes/pianta.tscn` | `[BASE]game/scenes/pianta.tscn` | Componente pianta riutilizzabile (sprite, barra, pulsanti annaffia/raccogli) | `game/scripts/pianta.gd` | ✅ M1.1 |


> **Milestone 1 aggiungerà:**
> - `game/scenes/pianta.tscn` — componente pianta riutilizzabile
> - `game/scenes/giardino.tscn` — scena principale con griglia multi-pianta
> - `game/scenes/shop.tscn` — interfaccia negozio

---

## 💻 SCRIPT GDSCRIPT (file .gd)

| File | URL raw | Scopo | Funzioni chiave | Stato |
|------|---------|-------|----------------|-------|
| `game/scripts/main.gd` | `[BASE]game/scripts/main.gd` | Giardino: istanzia N piante, gestisce semi globali, salva/carica stato | `_ready()`, `_su_raccolta_effettuata()`, `salva_dati()`, `carica_dati()` | ✅ M1.1 |
| `game/scripts/pianta.gd` | `[BASE]game/scripts/pianta.gd` | Logica singola pianta come componente autonomo. Emette segnali al giardino. | `carica_stato()`, `ottieni_stato()`, `applica_crescita_passiva()`, `aggiungi_acqua()` | ✅ M1.1 |


> **Milestone 1 aggiungerà:**
> - `game/scripts/pianta.gd` — logica singola pianta (componente autonomo)
> - `game/scripts/giardino.gd` — gestione griglia piante, UI, salvataggio
> - `game/scripts/dati_piante.gd` — database tipi di pianta (pothos, pachira, monstera...)
> - `game/scripts/shop.gd` — logica negozio e acquisti

---

## 🎨 ASSET (da aggiungere nelle milestone successive)

| Cartella | Contenuto previsto | Milestone |
|----------|--------------------|-----------|
| `game/assets/piante/` | Illustrazioni piante in vari stadi di crescita (PNG trasparente) | M3 |
| `game/assets/ui/` | Pulsanti, icone, sfondi UI | M2-M3 |
| `game/assets/audio/` | Musica lofi + effetti sonori | M2 |
| `game/assets/fonts/` | Font carino per UI | M2 |

---

## 🗺️ WORKFLOW CON CLAUDE

### Inizio sessione (ogni nuova chat)
```
1. Incolla HANDOFF.md
2. Incolla CODEMAP.md
3. Di' quale step vuoi fare
4. Claude chiede i file specifici che servono
5. Fornisci gli URL raw dei file richiesti
```

### Esempio prompt iniziale efficace
> *"Ciao Claude. Ti allego HANDOFF e CODEMAP del progetto PlantIdle. Repo: https://github.com/paguroaffitti-wq/PlantIdle. Sono pronto per Milestone 1 Step 1 — refactoring multi-pianta. Dimmi quali file ti servono."*

### URL raw pronti da copiare (Milestone 0)
```
Script principale:
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/scripts/main.gd

Scena principale:
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/main.tscn

Configurazione progetto:
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/project.godot
```

---

## 📝 CONVENZIONI DI NAMING

| Tipo | Convenzione | Esempio |
|------|-------------|---------|
| File Godot | snake_case | `pianta.gd`, `dati_piante.gd` |
| Nodi nelle scene | PascalCase | `PulsanteAnnaffia`, `BarraCrescita` |
| Variabili e funzioni | snake_case | `acqua_attuale`, `salva_dati()` |
| Costanti | SCREAMING_SNAKE_CASE | `ACQUA_PER_TAP`, `FILE_SALVATAGGIO` |
| Lingua variabili game logic | Italiano | `acqua_attuale`, `semi` |
| Lingua termini engine | Inglese | `_ready()`, `connect()`, `pressed` |

---

## 📊 STATO MILESTONE

| Milestone | Descrizione | Stato |
|-----------|-------------|-------|
| M0 | Prototipo pianta singola | ✅ Completata |
| M1 | Loop base multi-pianta + shop | 🔲 In partenza |
| M2 | Progressione e contenuti | 🔲 |
| M3 | Asset finali con AI | 🔲 |
| M4 | Mobile readiness | 🔲 |
| M5 | Monetizzazione | 🔲 |
| M6 | Pubblicazione Google Play | 🔲 |

---

*Ultimo aggiornamento: Maggio 2026 — Milestone 0 completata*
