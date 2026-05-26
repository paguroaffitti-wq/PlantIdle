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
| `HANDOFF.md` | `[BASE]HANDOFF.md` | Stato completo del progetto, piano, architettura |
| `CODEMAP.md` | `[BASE]CODEMAP.md` | Questo file — mappa di tutti i file |
| `DECISIONI.md` | `[BASE]DECISIONI.md` | Log decisioni importanti e motivazioni |
| `README.md` | `[BASE]README.md` | Presentazione pubblica del progetto su GitHub |

---

## ⚙️ CONFIGURAZIONE GODOT

| File | URL raw | Scopo | Stato |
|------|---------|-------|-------|
| `game/project.godot` | `[BASE]game/project.godot` | Config Godot: risoluzione 480x800, portrait, Autoload ProgressoGiocatore, tema globale | ✅ M1 |
| `game/icon.svg` | `[BASE]game/icon.svg` | Icona placeholder | ✅ M0 |

**Autoload registrato:** `ProgressoGiocatore` → `res://scripts/progresso_giocatore.gd`
**Tema globale:** `res://assets/theme/theme.tres`

---

## 🎨 ASSET

| File | URL raw | Scopo | Stato |
|------|---------|-------|-------|
| `game/assets/theme/theme.tres` | `[BASE]game/assets/theme/theme.tres` | Tema UI cottagecore globale: palette, pulsanti terracotta, stili Panel/ProgressBar | ✅ M1 |

> **Palette definita:**
> - Crema `#F5EFE0` — sfondo principale
> - Beige `#E8DFC8` — sfondo secondario / card
> - Salvia `#7BA05B` — verde principale (header)
> - Foresta `#4A6B3A` — verde scuro
> - Terracotta `#A87856` — vasi e pulsanti
> - Testo `#3D3A30` — testo principale

> **Variazioni tema definite:**
> - `Vaso` — Panel terracotta con bordo superiore per i vasi delle piante
> - `VasoVuoto` — Panel grigio traslucido per gli slot vuoti

---

## 🗃️ DATABASE PIANTE (risorse .tres)

Ogni file è un'istanza di `DatiPianta` (Resource). Per aggiungere una pianta: crea un nuovo `.tres`, compilalo nell'inspector, aggiungilo a `TUTTI_I_DATI` in `progresso_giocatore.gd`.

| File | URL raw | Tipo | Costo | Acqua | Passiva/s | Semi | Stato |
|------|---------|------|-------|-------|-----------|------|-------|
| `game/data/piante/pothos.tres` | `[BASE]game/data/piante/pothos.tres` | Pothos | Gratis | 60 | 1.5 | 8 | ✅ M1 |
| `game/data/piante/sansevieria.tres` | `[BASE]game/data/piante/sansevieria.tres` | Sansevieria | 30 semi | 100 | 1.0 | 12 | ✅ M1 |
| `game/data/piante/monstera.tres` | `[BASE]game/data/piante/monstera.tres` | Monstera | 80 semi | 180 | 0.8 | 25 | ✅ M1 |

> **Piante pianificate per M2:** pachira, calathea, pilea, aloe, cactus, orchidea...

---

## 🎬 SCENE GODOT (file .tscn)

| File | URL raw | Scopo | Script | Stato |
|------|---------|-------|--------|-------|
| `game/main.tscn` | `[BASE]game/main.tscn` | Scena giardino: header salvia, GridContainer 2 colonne con ScrollContainer, pulsante shop | `scripts/main.gd` | ✅ M1 |
| `game/scenes/pianta.tscn` | `[BASE]game/scenes/pianta.tscn` | Componente pianta 220px: 3 nodi foglia + Panel vaso + barra + pulsanti + label nome | `scripts/pianta.gd` | ✅ M1 |
| `game/scenes/vaso_vuoto.tscn` | `[BASE]game/scenes/vaso_vuoto.tscn` | Placeholder slot vuoto 220px: sfondo grigio + Panel vaso + pulsante "Pianta qui" | `scripts/vaso_vuoto.gd` | ✅ M1 |
| `game/scenes/shop.tscn` | `[BASE]game/scenes/shop.tscn` | Scena negozio separata: header, scroll lista piante, sezione vasi, pulsante indietro | `scripts/shop.gd` | ✅ M1 |

> **Note layout:**
> - `main.tscn` usa `GridContainer` (2 colonne) dentro `ScrollContainer` per gestire 1-6 vasi
> - Con 1-3 piante la terza appare centrata da sola — comportamento atteso
> - Con 4-6 piante la griglia si riempie; scroll verticale disponibile se necessario

---

## 💻 SCRIPT GDSCRIPT (file .gd)

| File | URL raw | Scopo | Funzioni chiave | Stato |
|------|---------|-------|-----------------|-------|
| `game/scripts/dati_pianta.gd` | `[BASE]game/scripts/dati_pianta.gd` | `class_name DatiPianta extends Resource` — scheda tecnica di un tipo di pianta, campi @export editabili nell'inspector | — (è una Resource, non ha logica) | ✅ M1 |
| `game/scripts/progresso_giocatore.gd` | `[BASE]game/scripts/progresso_giocatore.gd` | Singleton (Autoload). Unica fonte di verità: semi, piante sbloccate, vasi, slot. Gestisce salvataggio v3. | `sblocca_pianta()`, `compra_vaso()`, `pianta_nello_slot()`, `aggiorna_stato_slot()`, `salva()`, `carica()` | ✅ M1 |
| `game/scripts/main.gd` | `[BASE]game/scripts/main.gd` | Giardino: legge stato da singleton, istanzia Pianta o VasoVuoto per ogni slot, gestisce crescita passiva | `ricostruisci_giardino()`, `_su_timer_crescita()`, `_su_click_vaso_vuoto()` | ✅ M1 |
| `game/scripts/pianta.gd` | `[BASE]game/scripts/pianta.gd` | `class_name Pianta`. Componente autonomo: 3 stadi visivi, animazione pop maturazione, label +semi fluttuante. Comunica via segnali. | `imposta()`, `ottieni_stato()`, `applica_crescita_passiva()`, `aggiorna_visuale()` | ✅ M1 |
| `game/scripts/vaso_vuoto.gd` | `[BASE]game/scripts/vaso_vuoto.gd` | `class_name VasoVuoto`. Placeholder slot vuoto, emette `click_pianta_qui` al giardino | `_ready()` | ✅ M1 |
| `game/scripts/shop.gd` | `[BASE]game/scripts/shop.gd` | Logica negozio: genera card piante colorate dinamicamente, gestisce acquisto vasi, ascolta segnali singleton | `aggiorna_lista_piante()`, `crea_card_pianta()`, `aggiorna_sezione_vasi()` | ✅ M1 |

---

## 🔌 SEGNALI (comunicazione tra componenti)

| Segnale | Emesso da | Ascoltato da | Quando |
|---------|-----------|--------------|--------|
| `raccolta_effettuata(quantita)` | `Pianta` | `main.gd` | Il giocatore preme ✂️ su una pianta matura |
| `stato_cambiato` | `Pianta` | `main.gd` | Acqua cambia o raccolta avviene → triggera salvataggio |
| `click_pianta_qui` | `VasoVuoto` | `main.gd` | Il giocatore preme "Pianta qui" → apre PopupMenu |
| `semi_cambiati(n)` | `ProgressoGiocatore` | `main.gd`, `shop.gd` | Semi aumentano o diminuiscono → aggiorna UI |
| `pianta_sbloccata(id)` | `ProgressoGiocatore` | `shop.gd` | Acquisto completato → rimuove card dallo shop |
| `vaso_aggiunto(n)` | `ProgressoGiocatore` | `shop.gd` | Vaso comprato → aggiorna sezione vasi |

---

## 💾 FORMATO SALVATAGGIO

**File:** `user://salvataggio.save` (JSON)
**Versione attuale:** 3
**Versioni precedenti:** scartate silenziosamente (nessuna migrazione — durante sviluppo solo il dev testa)

```json
{
  "versione": 3,
  "semi": 42,
  "timestamp": 1716900000.0,
  "piante_sbloccate": ["pothos", "sansevieria"],
  "numero_vasi": 4,
  "slot_piante": [
    {"id_pianta": "pothos",      "acqua_attuale": 45.0, "matura": false},
    {"id_pianta": "sansevieria", "acqua_attuale": 100.0, "matura": true},
    {"id_pianta": "",            "acqua_attuale": 0.0,  "matura": false},
    {"id_pianta": "",            "acqua_attuale": 0.0,  "matura": false}
  ]
}
```

**Crescita offline:** calcolata in `ProgressoGiocatore.carica()` prima che il giardino istanzi i nodi. Ogni pianta non matura riceve `secondi_offline × acqua_passiva_al_secondo` di acqua.

---

## 🗺️ WORKFLOW CON CLAUDE

### Inizio sessione (ogni nuova chat)
```
1. Incolla HANDOFF.md
2. Incolla CODEMAP.md
3. Di' quale milestone/step vuoi fare
4. Claude legge i file dal repo GitHub se serve
```

### URL raw pronti da copiare
```
Singleton:
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/scripts/progresso_giocatore.gd

Script giardino:
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/scripts/main.gd

Script pianta:
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/scripts/pianta.gd

Script shop:
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/scripts/shop.gd

Scena principale:
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/main.tscn

Dati pianta (risorsa base):
https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/scripts/dati_pianta.gd
```

---

## 📝 CONVENZIONI DI NAMING

| Tipo | Convenzione | Esempio |
|------|-------------|---------|
| File Godot | snake_case | `pianta.gd`, `dati_pianta.gd` |
| Nodi nelle scene | PascalCase | `PulsanteAnnaffia`, `ContenitorePiante` |
| Variabili e funzioni | snake_case | `acqua_attuale`, `salva_dati()` |
| Costanti | SCREAMING_SNAKE_CASE | `ACQUA_PER_TAP`, `FILE_SALVATAGGIO` |
| ID piante nei .tres | snake_case minuscolo | `"pothos"`, `"sansevieria"` |
| Lingua variabili game logic | Italiano | `acqua_attuale`, `semi` |
| Lingua termini engine | Inglese | `_ready()`, `connect()`, `pressed` |

---

## 📊 STATO MILESTONE

| Milestone | Descrizione | Stato |
|-----------|-------------|-------|
| M0 | Prototipo pianta singola | ✅ Completata |
| M1 | Loop base multi-pianta + shop + estetica | ✅ Completata |
| M2 | Progressione e contenuti | 🔲 Prossima |
| M3 | Asset finali con AI | 🔲 |
| M4 | Mobile readiness | 🔲 |
| M5 | Monetizzazione | 🔲 |
| M6 | Pubblicazione Google Play | 🔲 |

---

*Ultimo aggiornamento: Maggio 2026 — Milestone 1 completata*
