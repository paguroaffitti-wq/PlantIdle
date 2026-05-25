# 🌱 PIANTA CRESCENTE - Documento di Handoff Progetto

> **Cos'è questo documento:** un riepilogo strutturato del progetto da incollare all'inizio di ogni nuova conversazione con un'AI (Claude, ChatGPT, ecc.) per non perdere il contesto. Aggiornalo dopo ogni milestone completata.

---

## 📋 IDENTITÀ DEL PROGETTO

**Nome di lavoro:** PiantaCrescente (nome finale da decidere più avanti)

**Tipo di prodotto:** Mobile game Android (iOS in futuro), genere idle/non-idle, free-to-play con in-app purchase opzionali.

**Concept in una frase:** Un cozy idle game dove il giocatore colleziona e cura piante d'appartamento realistiche (pachira, monstera, pothos...) con qualche pianta kawaii speciale.

**Riferimento principale:** [Window Garden - Lofi Idle Game](https://play.google.com/store/apps/details?id=com.cloverfi.windowgarden) di Cloverfi Games. Stile 2D piatto cottagecore vista frontale.

**Target audience:** 20-70 anni, plant lovers, persone che cercano un'esperienza rilassante e collezionistica su mobile.

**Esperienza che voglio dare:** rilassante, collezionistica, con una piccola componente sociale "lite" (es. codici condivisibili per mostrare il proprio giardino agli amici, da implementare in v2).

---

## 👤 PROFILO DELLO SVILUPPATORE

- **Background:** sa programmare ma non ha esperienza gamedev
- **Tempo disponibile:** 2-5 ore a settimana (side hustle, non lavoro full-time)
- **Motivazione principale:** avere un progetto creativo proprio (le entrate sono un bonus, non l'obiettivo)
- **Hardware:** PC Windows + Mac (per future build iOS) + smartphone Android per test
- **Strumenti AI disponibili:** ChatGPT (per generazione immagini), Claude (per codice e pianificazione)

---

## 🛠️ STACK TECNICO DECISO

- **Game engine:** Godot 4.3 Standard (NON la versione .NET/C#)
- **Linguaggio:** GDScript
- **Target di build primario:** Android (Google Play)
- **Risoluzione:** 480x800 verticale (portrait mobile)
- **Generazione asset:** ChatGPT/DALL-E per illustrazioni piante (eventualmente Scenario.gg in futuro per maggiore coerenza di stile)

---

## 🎨 STILE VISIVO SCELTO

**Per la v1.0:**
- 2D piatto / vista frontale
- Stile cottagecore / cozy / illustrato
- Atmosfera calda, colori naturali ma vivi
- UI pulita con font carino e leggibile
- NO isometrico per la v1 (rimandato a v2.0 se il gioco ha successo)

**Riferimento estetico:** Window Garden, illustrazioni botaniche flat moderne, palette colori warm earthtones.

**NB:** È stata vista e ammirata una grafica isometrica cozy molto curata (livello Animal Crossing Pocket Camp / Cozy Grove), ma è stata riconosciuta come obiettivo a lungo termine (v2.0+), non per la v1.

---

## 📅 PIANO STRATEGICO COMPLETO (timeline realistica)

### Strategia generale: "Validare prima di investire"
Pubblicare una v1.0 funzionante in 6-8 mesi, vedere se la gente gioca, e *solo se ha trazione* investire in una v2.0 più bella (eventualmente isometrica).

### Milestone 0 — Prototipo "Una pianta che cresce" ✅ COMPLETATA
- Prototipo Godot con una pianta singola, annaffia, raccogli, salvataggio, crescita offline.
- Test su PC Windows superato.

### Milestone 1 — Loop base (target: 4-6 settimane)
- **Step 1:** Refactoring per gestire più piante contemporaneamente (3-6 vasi in griglia)
- **Step 2:** Tipi di pianta diversi (pothos, pachira, monstera) con stats diverse
- **Step 3:** Sistema shop + valuta (vendere foglie raccolte → monete → comprare nuove piante/vasi)
- **Step 4:** Prima estetica decente con asset temporanei (sprite colorate stilizzate, non finali)

### Milestone 2 — Progressione e contenuti (target: 4-6 settimane)
- Sistema livelli giocatore
- 10-15 piante diverse sbloccabili progressivamente
- Sistema "missioni giornaliere" per dare obiettivi
- Bilanciamento economy (acqua, monete, tempi di crescita)
- Prima musica/audio (lofi gratuita da fonti libere royalty-free)

### Milestone 3 — Asset finali (target: 6-8 settimane)
- Definizione style guide con ChatGPT
- Generazione delle illustrazioni finali di tutte le piante (in più stadi di crescita)
- Sostituzione di tutti gli asset placeholder
- UI finale polished
- Animazioni base (crescita, raccolta, transizioni)

### Milestone 4 — Mobile readiness (target: 3-4 settimane)
- Setup export Android
- Test su smartphone reale
- Fix specifici mobile (performance, gestione life cycle, touch UX)
- Adattamento risoluzioni multiple

### Milestone 5 — Monetizzazione (target: 2-3 settimane)
- In-app purchase base (1-3 prodotti tipo "starter pack", "rimuovi attesa", "valuta premium")
- Eventuale pubblicità non invasiva (rewarded ads opzionali per bonus)
- Integrazione AdMob/Google Play Billing

### Milestone 6 — Pubblicazione (target: 2-3 settimane)
- Account Google Play Developer (25$ una tantum)
- Store listing (screenshot, descrizione, icona)
- Soft launch in pochi paesi
- Pubblicazione globale
- Marketing minimo: Reddit (r/plants, r/houseplants), TikTok, post su community plant lovers

### TOTALE TIMELINE REALISTICA: 8-12 mesi part-time

---

## 💰 BUDGET PREVISTO

- **Godot:** gratuito
- **Google Play Developer Account:** 25$ una tantum
- **ChatGPT Plus:** ~22€/mese (per generazione immagini illimitata-ish)
- **Eventuale Scenario.gg:** 30-50$/mese se servisse più coerenza visiva
- **Musica/SFX royalty-free:** 0-50€ una tantum (Pixabay/Freesound) o 200-500€ se si vuole licensing premium
- **TOTALE STIMATO:** 200-600€ in 12 mesi (escluso costo del tempo)

---

## 🎯 PROSSIMO STEP IMMEDIATO

**Milestone 1, Step 1:** Refactoring del codice per supportare 3 vasi/piante contemporaneamente in griglia, invece di una sola pianta centrale.

**Cosa serve da fare in chat:**
1. Aprire una nuova conversazione
2. Incollare questo documento di handoff in apertura
3. Dire a Claude: "Sono pronto per partire con Milestone 1 Step 1"
4. Claude preparerà i file Godot aggiornati
5. Tu li scarichi, sostituisci nel progetto esistente, testi

---

## 📝 NOTE E DECISIONI IMPORTANTI

- **Vista isometrica:** rimandata a v2.0 dopo validazione del prodotto. Non per impossibilità tecnica, ma per priorità di shipping.
- **Componente social:** rimandata a v2.0 (richiederebbe backend e costi server). Per v1 niente community feature dentro il gioco; eventualmente Discord/Instagram esterni.
- **Multilingua:** v1 in italiano + inglese minimo. Altre lingue dopo lancio se utenti lo chiedono.
- **iOS:** rimandato. Si valuta solo dopo che Android funziona ed eventualmente genera entrate.
- **Approccio AI per asset:** ChatGPT/DALL-E per la v1, con uno style guide preciso per garantire coerenza. Eventuale upgrade a Scenario.gg in Milestone 3 se la coerenza non è sufficiente.

---

## ⚠️ COSE DA NON DIMENTICARE MAI

1. **Il gioco è un side hustle, non un lavoro:** se in qualche settimana non ho tempo, non è un problema. Meglio fare poco ma costante che bruciarsi.
2. **Validare prima di investire:** non aggiungere feature complesse (sociale, isometrico, eventi) prima di sapere se il gioco base ha pubblico.
3. **Le aspettative di guadagno sono basse:** il 95% degli indie game mobile non ripaga il tempo speso. Questo progetto è prima di tutto un percorso di apprendimento e creatività.
4. **L'AI accelera, non sostituisce:** ChatGPT/Claude aiutano molto ma il giudizio finale, il gusto, le decisioni di game design sono mie.
5. **Brutto ma funzionante > bello ma incompleto:** durante tutte le milestone tecniche, accettare grafica placeholder. La bellezza arriva alla Milestone 3.

---

## 📞 STATO ATTUALE DEL PROGETTO

**Ultima milestone completata:** Milestone 0 - Prototipo "Una pianta che cresce"
**Data ultimo aggiornamento documento:** [DA AGGIORNARE A OGNI MILESTONE]
**File progetto Godot:** salvati localmente in `C:\GameDev\PiantaCrescente\` (o percorso scelto)
**Prossima azione:** Iniziare nuova conversazione AI con questo documento in apertura, partire con Milestone 1 Step 1.
