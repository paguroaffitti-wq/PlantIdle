# 🌱 Milestone 0 — Una pianta che cresce

Benvenuto al primo prototipo! Questa guida ti porta da zero a "gioco funzionante sul tuo PC" in circa 30-45 minuti.

---

## Cosa stiamo costruendo

Un mini-gioco con:
- Una pianta (un quadrato verde, per ora!) che cresce
- Un pulsante "Annaffia" che la fa crescere più velocemente
- Crescita automatica nel tempo (il cuore dell'idle game)
- Raccolta di "semi" quando la pianta è matura
- Salvataggio automatico, anche se chiudi tutto
- Crescita "offline": se torni dopo ore, la pianta sarà cresciuta!

**Niente grafica fancy.** Le forme sono rettangoli colorati. È voluto: dobbiamo prima far funzionare la meccanica, poi penseremo alla bellezza. Tu intanto puoi cominciare a pensare a come vuoi che siano le piante "vere".

---

## STEP 1 — Installa Godot (10 minuti)

1. Vai su **https://godotengine.org/download/windows/**
2. Scarica **Godot Engine 4.3 (Standard)** — il file `.exe` da circa 80 MB
3. ⚠️ NON scaricare la versione ".NET" / "C#". A noi serve quella standard con GDScript.
4. **Godot non si installa**: è un singolo file `.exe`. Crea una cartella tipo `C:\Godot\` e mettilo lì.
5. Crea un collegamento sul desktop al file `Godot_v4.3-stable_win64.exe`

Tutto qui. Godot non aggiunge cose al registro di sistema, non ha installer, non ha servizi in background. È letteralmente un programma portatile.

---

## STEP 2 — Apri il progetto (5 minuti)

1. Scompatta i file del progetto in una cartella dedicata, ad esempio:
   `C:\GameDev\PiantaCrescente\`
2. Apri Godot (doppio click sull'eseguibile)
3. Si apre il **Project Manager**. Clicca su **"Importa"** (Import)
4. Naviga fino alla cartella `PiantaCrescente` e seleziona il file **`project.godot`**
5. Clicca **"Importa & modifica"** (Import & Edit)

Godot impiegherà 10-20 secondi a importare. Vedrai apparire l'editor con il progetto aperto.

---

## STEP 3 — Fai partire il gioco (1 minuto)

In alto a destra nell'editor c'è un **pulsante triangolare ▶ (Play)**.

Cliccalo.

Si aprirà una finestra verticale (tipo telefono) con:
- Sfondo verde chiaro
- Un quadrato verde scuro al centro (la "pianta")
- Una barra di progresso vuota
- Il testo "Annaffia la pianta!"
- Due pulsanti grandi in basso

**Premi "💧 ANNAFFIA"** ripetutamente. Vedrai:
- La barra che si riempie
- La pianta che diventa più grande e più verde
- Quando la barra è piena, il testo cambia in "Pianta matura! Raccogli!"
- Il pulsante "RACCOGLI" diventa attivo

Premi raccogli → ottieni 10 semi → si ricomincia.

**Test idle:** chiudi il gioco, aspetta 1-2 minuti, riaprilo. Vedrai che la pianta è cresciuta da sola nel frattempo! Questa è la magia dell'idle game.

---

## STEP 4 — Esplora un po' (10 minuti, opzionale ma consigliato)

Mentre il gioco è in esecuzione, prova a smanettare:

- **Apri `scripts/main.gd`** (doppio click nel pannello Files in basso a sinistra)
- In cima al file vedi le **"costanti di gioco"**:
  ```
  const ACQUA_PER_CRESCITA: float = 100.0
  const ACQUA_PER_TAP: float = 5.0
  const TEMPO_CRESCITA_AUTO: float = 1.0
  ```
- Cambia i numeri (ad esempio metti `ACQUA_PER_TAP = 50.0`) e salva con `Ctrl+S`
- Premi di nuovo Play — ora ogni tap riempie metà barra!

Questo è il **game balancing**: si gioca con i numeri finché il gioco non "si sente" bene. È metà del lavoro di un game designer.

---

## STEP 5 — Resetta il salvataggio (utile per testare)

Il gioco salva i tuoi progressi in una cartella nascosta. Se vuoi ricominciare da zero:

1. Premi `Win + R`, scrivi `%APPDATA%` e premi Invio
2. Vai in `Godot\app_userdata\PiantaCrescente\`
3. Elimina il file `salvataggio.save`

Oppure più semplicemente: dal menu di Godot, **Project → Open User Data Folder** → elimina il file `.save`.

---

## Cosa fare quando hai finito

Quando hai testato tutto, **fammi sapere**:

1. ✅ È partito senza errori?
2. ✅ Capisci che cosa fa ogni parte?
3. ✅ Hai provato a modificare i numeri?
4. 🐛 C'è qualcosa che si comporta in modo strano?
5. 💭 Cosa pensi del "feeling" del gioco? È divertente già adesso, o noioso?

Da qui in poi, le **prossime tappe** in ordine:

- **Milestone 1:** più tipi di piante, sistema di shop, valuta di gioco vera
- **Milestone 2:** progressione e sblocchi, prima estetica decente
- **Milestone 3:** le tue grafiche al posto dei rettangoli
- **Milestone 4:** export su Android, test sul tuo telefono
- **Milestone 5:** monetizzazione (in-app purchase, eventualmente pubblicità)
- **Milestone 6:** pubblicazione su Google Play

Ognuna è 2-4 settimane di lavoro al tuo ritmo. Non pensarci adesso, concentrati sulla 0!

---

## Se qualcosa va storto

I problemi più comuni:

**"Mi dà errore quando importo il progetto"**
→ Probabilmente hai scaricato la versione .NET di Godot. Devi avere la versione "Standard". Disinstalla e scarica quella giusta.

**"Il pulsante Annaffia non fa niente"**
→ Apri il pannello "Output" in basso nell'editor. Lì vedi gli errori. Copiamelo e te lo risolvo.

**"La pianta non si vede"**
→ Verifica di aver cliccato Play e che la finestra sia davvero quella verticale del gioco, non un'altra.

**"Voglio cambiare i colori / la forma"**
→ Aspetta! Lo faremo nelle milestone successive con le tue grafiche. Per ora resistiamo all'urge di abbellire.

Per qualsiasi cosa, copia-incolla l'errore o descrivi cosa vedi e ne parliamo.

Buon divertimento! 🌱
