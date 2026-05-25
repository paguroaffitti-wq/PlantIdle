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

- **Game engine:** Godot 4.3 Standard (NON la versione .NET/C#)
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
- Atmosfera calda, colori naturali ma vivi
- UI pulita con font carino e leggibile
- Piante d'appartamento realistiche (pachira, monstera, pothos, sansevieria...) + qualche pianta kawaii speciale

**Rimandato a v2.0:**
- Vista isometrica (stile Animal Crossing Pocket Camp)
- Componente social con backend

**Riferimenti estetici:** Window Garden, Viridi, illustrazioni botaniche flat moderne, palette warm earthtones.

---

## 📁 STRUTTURA REPOSITORY

```
PlantIdle/                  ← root repo GitHub
├── .gitignore              ← ignora .godot/, *.import, build/, ecc.
├── README.md               ← presentazione pubblica del progetto
├── HANDOFF.md              ← questo file
├── CODEMAP.md              ← mappa di tutti i file e script
├── DECISIONI.md            ← log decisioni importanti
└── game/                   ← progetto Godot
    ├── project.godot
    ├── main.tscn
    ├── icon.svg
    └── scripts/
        └── main.gd
```

**URL base per file raw GitHub:**
`https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/`

**Esempi URL raw:**
- `https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/game/scripts/main.gd`
- `https://raw.githubusercontent.com/paguroaffitti-wq/PlantIdle/main/CODEMAP.md`

---

## 📅 PIANO STRATEGICO COMPLETO

### Strategia generale: "Validare prima di investire"
Pubblicare una v1.0 funzionante in 8-12 mesi, vedere se la gente gioca, e solo se ha trazione investire in v2.0 isometrica.

### Milestone 0 — Prototipo "Una pianta che cresce" ✅ COMPLETATA
- Una pianta singola, annaffia, raccogli, salvataggio automatico, crescita offline
- Testato su PC Windows, funzionante
- Repository GitHub configurata e pulita

### Milestone 1 — Loop base multi-pianta 🔲 IN CORSO
- **Step 1:** Refactoring per gestire più piante (3-6 vasi in griglia) ✅ COMPLETATO
- **Step 2:** Tipi di pianta diversi (pothos, pachira, monstera) con stats diverse 🔲 PROSSIMO
- **Step 3:** Sistema shop + valuta (vendi foglie → monete → compra piante/vasi)
- **Step 4:** Prima estetica con asset temporanei stilizzati

### Milestone 2 — Progressione e contenuti 🔲
- Sistema livelli giocatore
- 10-15 piante sbloccabili progressivamente
- Missioni giornaliere
- Bilanciamento economy
- Prima musica/audio lofi (royalty-free)

### Milestone 3 — Asset finali 🔲
- Style guide con ChatGPT
- Illustrazioni finali di tutte le piante (3-5 stadi di crescita ciascuna)
- Sostituzione tutti i placeholder
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

**Ultima milestone completata:** Milestone 1 Step 1 ✅
**Prossimo step:** Milestone 1, Step 2 — tipi di pianta diversi

**Come iniziare la prossima sessione:**
1. Apri nuova conversazione con Claude
2. Incolla HANDOFF.md + CODEMAP.md
3. Di': *"Partiamo con Milestone 1 Step 1 — refactoring multi-pianta"*
4. Se Claude ha bisogno di vedere un file, fornisci l'URL raw da GitHub

---

## ⚠️ PRINCIPI DA NON DIMENTICARE

1. **Validare prima di investire** — non aggiungere feature complesse prima di avere utenti reali
2. **Brutto ma funzionante > bello ma incompleto** — placeholder ok fino alla Milestone 3
3. **Una chat = uno step** — chat pulite, contesto limitato, più efficienza
4. **Commit dopo ogni sessione** — `git add . && git commit -m "..." && git push`
5. **Le entrate sono un bonus** — il progetto è prima di tutto un percorso creativo
