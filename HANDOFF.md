# 🌱 PLANTIDLE - Documento di Handoff Progetto

> **Cos'è questo documento:** riepilogo completo del progetto da incollare all'inizio di ogni nuova conversazione con un'AI (Claude, ChatGPT, ecc.) per non perdere il contesto.
> **Come usarlo:** incolla questo file + CODEMAP.md all'inizio di ogni nuova chat. L'AI avrà tutto il contesto necessario.
> **Aggiornamento:** aggiornare la sezione "Stato attuale" dopo ogni milestone completata.

---

## 📋 IDENTITÀ DEL PROGETTO

**Nome progetto:** PlantIdle
**Nome di lavoro interno:** PlantIdle (nome finale da definire in Milestone 2)
**Repository GitHub:** https://github.com/paguroaffitti-wq/PlantIdle

**Tipo di prodotto:** Mobile game Android (iOS possibile in futuro), genere idle/non-idle, free-to-play con in-app purchase opzionali.

**Concept in una frase:** Un cozy idle game dove il giocatore colleziona e cura piante d'appartamento realistiche (pachira, monstera, pothos...) con qualche pianta kawaii speciale, in un appartamento virtuale rilassante.

**Riferimento principale:** Window Garden (Cloverfi Games) su Google Play. Stile 2D piatto cottagecore, vista frontale, atmosfera lofi e rilassante.

**Esperienza che voglio dare al giocatore:** rilassante, collezionistica, con componente sociale "lite" in v2 (codici condivisibili per mostrare il proprio giardino).

---

## 👤 PROFILO DELLO SVILUPPATORE

- **Background:** sa programmare ma zero esperienza gamedev
- **Tempo disponibile:** 2-5 ore a settimana (side hustle)
- **Motivazione principale:** progetto creativo proprio (entrate = bonus, non obiettivo primario)
- **Hardware:** PC Windows + Mac (futuro iOS) + smartphone Android per test
- **Strumenti AI:** Claude (codice, architettura, pianificazione) + ChatGPT/DALL-E (asset visivi)

---

## 🛠️ STACK TECNICO

- **Game engine:** Godot 4.6 Standard (NON la versione .NET/C#)
- **Linguaggio:** GDScript
- **Target primario:** Android (Google Play)
- **Risoluzione:** 480x800 verticale (portrait mobile)
- **Generazione asset:** ChatGPT/DALL-E per illustrazioni (eventualmente Scenario.gg per coerenza di stile)
- **Versioning:** Git + GitHub (repo pubblica)
- **Tool Git:** GitHub Desktop per uso quotidiano, Git Bash per operazioni avanzate

---

## 🎨 STILE VISIVO

**Per la v1.0:**
- 2D piatto / vista frontale
- Stile cottagecore / cozy / illustrato
- Palette calda definita: crema `#F5EFE0`, beige `#E8DFC8`, salvia `#7BA05B`, foresta `#4A6B3A`, terracotta `#A87856`
- UI con tema Godot custom (angoli arrotondati, pulsanti terracotta, header salvia)
- Piante d'appartamento realistiche (pachira, monstera, pothos, sansevieria...) + qualche pianta kawaii speciale
- Griglia 2 colonne per il giardino, espandibile fino a 6 vasi

**Rimandato a v2.0:**
- Vista isometrica (stile Animal Crossing Pocket Camp)
- Componente social con backend

**Riferimenti estetici:** Window Garden, Viridi, illustrazioni botaniche flat moderne, palette warm earthtones.

---

## 📁 STRUTTURA REPOSITORY

```
PlantIdle/                      ← root repo GitHub
├── .gitignore
├── README.md
├── HANDOFF.md                  ← questo file
├── CODEMAP.md
├── DECISIONI.md
└── game/                       ← progetto Godot
    ├── project.godot            ← Autoload ProgressoGiocatore + tema globale
    ├── main.tscn                ← scena giardino principale
    ├── icon.svg
    ├── assets/
    │   └── theme/
    │       └── theme.tres       ← tema UI cottagecore globale
    ├── data/
    │   └── piante/
    │       ├── pothos.tres
    │       ├── sansevieria.tres
    │       └── monstera.tres
    ├── scenes/
    │   ├── pianta.tscn
    │   ├── vaso_vuoto.tscn
    │   └── shop.tscn
    └── scripts/
        ├── main.gd
        ├── pianta.gd
        ├── vaso_vuoto.gd
        ├── dati_pianta.gd
        ├── progresso_giocatore.gd
        └── shop.gd
```

**URL base per file raw GitHub:**
`https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/`

---

## 🏗️ ARCHITETTURA ATTUALE (post M1)

### Pattern generale
Il gioco segue un pattern **MVC leggero**:
- **Model:** `ProgressoGiocatore` (singleton/Autoload) — unica fonte di verità su semi, piante sbloccate, slot, vasi
- **View:** scene Godot (`pianta.tscn`, `vaso_vuoto.tscn`, `shop.tscn`) — mostrano lo stato, non lo possiedono
- **Controller:** script (`main.gd`, `shop.gd`) — orchestrano le interazioni tra view e model

### Flusso dati
```
Giocatore interagisce con Pianta
    → Pianta emette segnale (raccolta_effettuata / stato_cambiato)
    → main.gd ascolta e aggiorna ProgressoGiocatore
    → ProgressoGiocatore salva su disco
    → UI si aggiorna via segnale semi_cambiati
```

### Singleton: ProgressoGiocatore
Accessibile da qualsiasi scena. Contiene:
- `semi: int` — valuta globale
- `piante_sbloccate: Dictionary` — set di id sbloccati
- `numero_vasi: int` — da 3 a MAX_VASI (6)
- `slot_piante: Array` — stato di ogni slot (id_pianta + acqua + maturità)
- `TUTTI_I_DATI: Dictionary` — database di tutti i tipi di pianta (preload dei .tres)

### Database piante: risorse .tres
Ogni tipo di pianta è un file `DatiPianta` (Resource) in `data/piante/`. Campi: id, nome, descrizione, costo_sblocco, acqua_per_crescita, acqua_per_tap, acqua_passiva_al_secondo, semi_per_raccolto, colori placeholder, texture finali (vuote fino a M3).

### Salvataggio
File JSON in `user://salvataggio.save`, versione 3. Formato:
```json
{
  "versione": 3,
  "semi": 42,
  "timestamp": 1234567890.0,
  "piante_sbloccate": ["pothos", "sansevieria"],
  "numero_vasi": 4,
  "slot_piante": [
    {"id_pianta": "pothos", "acqua_attuale": 30.0, "matura": false},
    {"id_pianta": "sansevieria", "acqua_attuale": 0.0, "matura": true},
    {"id_pianta": "", ...},
    {"id_pianta": "", ...}
  ]
}
```

---

## 📅 PIANO STRATEGICO COMPLETO

### Strategia generale: "Validare prima di investire"
Pubblicare una v1.0 funzionante in 8-12 mesi, vedere se la gente gioca, e solo se ha trazione investire in v2.0 isometrica.

### Milestone 0 — Prototipo "Una pianta che cresce" ✅ COMPLETATA
- Una pianta singola, annaffia, raccogli, salvataggio automatico, crescita offline
- Testato su PC, funzionante, repository configurata

### Milestone 1 — Loop base multi-pianta ✅ COMPLETATA
- **Step 1:** Refactoring multi-pianta con architettura a componenti e segnali
- **Step 2:** Tipi di pianta data-driven con risorse .tres (pothos, sansevieria, monstera)
- **Step 3:** Sistema shop + valuta semi + singleton ProgressoGiocatore + vasi espandibili
- **Step 4:** Estetica cottagecore (palette, tema globale, stadi crescita, animazioni, griglia 2 colonne)

### Milestone 2 — Progressione e contenuti 🔲 PROSSIMA
- Sistema livelli giocatore
- 10-15 piante sbloccabili progressivamente (pachira, calathea, pilea, aloe...)
- Missioni giornaliere
- Bilanciamento economy
- Prima musica/audio lofi (royalty-free)

### Milestone 3 — Asset finali 🔲
- Style guide con ChatGPT
- Illustrazioni finali di tutte le piante (3-5 stadi di crescita ciascuna)
- Sostituzione tutti i placeholder ColorRect con Sprite2D
- UI finale polished
- Animazioni base

### Milestone 4 — Mobile readiness 🔲
- Setup export Android in Godot
- Test su smartphone reale
- Fix specifici mobile (performance, touch UX, lifecycle)
- Adattamento risoluzioni multiple

### Milestone 5 — Monetizzazione 🔲
- In-app purchase (starter pack, rimuovi attesa, valuta premium)
- Rewarded ads opzionali (non invasive)
- Integrazione Google Play Billing

### Milestone 6 — Pubblicazione 🔲
- Account Google Play Developer (25$ una tantum)
- Store listing (screenshot, descrizione, icona)
- Soft launch → pubblicazione globale
- Marketing: Reddit (r/houseplants, r/AndroidGaming), TikTok, community plant lovers

**Timeline realistica totale: 8-12 mesi part-time**

---

## 💰 BUDGET PREVISTO

| Voce | Costo |
|------|-------|
| Godot | Gratuito |
| GitHub | Gratuito |
| Google Play Developer | 25$ una tantum |
| ChatGPT Plus | ~22€/mese |
| Musica royalty-free | 0-50€ una tantum |
| **Totale stimato 12 mesi** | **~300-600€** |

---

## 📝 STATO ATTUALE

**Ultima milestone completata:** Milestone 1 ✅ (tutti e 4 gli step)
**Prossimo step:** Milestone 2, Step 1 — sistema livelli giocatore + nuove piante
**Data ultimo aggiornamento:** Maggio 2026

**Come iniziare la prossima sessione:**
1. Apri nuova conversazione con Claude
2. Incolla HANDOFF.md + CODEMAP.md
3. Di': *"Partiamo con Milestone 2"*
4. Claude leggerà i file dal repo GitHub se necessario

---

## ⚠️ PRINCIPI DA NON DIMENTICARE

1. **Validare prima di investire** — non aggiungere feature complesse prima di avere utenti reali
2. **Brutto ma funzionante > bello ma incompleto** — placeholder ok fino alla Milestone 3
3. **Una chat = uno step** — chat pulite, contesto limitato, più efficienza
4. **Commit dopo ogni sessione** — `git add . && git commit -m "..." && git push`
5. **Le entrate sono un bonus** — il progetto è prima di tutto un percorso creativo
6. **Il save è versionato** — quando cambia il formato, bumpa la versione e scarta i vecchi (finché sei solo tu a testare)
7. **Ogni pianta è una risorsa .tres** — per aggiungere piante basta creare il file, niente codice
