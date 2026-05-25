# 📋 LOG DELLE DECISIONI IMPORTANTI

> **A cosa serve:** tenere traccia delle decisioni significative prese durante lo sviluppo e del *perché* sono state prese. Quando tra 6 mesi ti chiederai "ma perché avevamo scelto X invece di Y?", la risposta sarà qui.

---

## Formato delle entry

Ogni decisione è un blocco con:
- **Data**
- **Decisione**
- **Alternative considerate**
- **Motivazione**
- **Conseguenze attese**

---

## DECISIONI PRESE

### Decisione #001 - Game engine: Godot 4.3
- **Data:** Maggio 2026
- **Decisione:** Usare Godot 4.3 (versione Standard, NON .NET) con linguaggio GDScript
- **Alternative considerate:** Unity, Flutter+Flame, GameMaker, Defold, soluzioni no-code (Construct 3, GDevelop)
- **Motivazione:** Godot è gratuito, open source, leggero, ottimo per 2D mobile, GDScript ha sintassi tipo Python più veloce da scrivere. Per un cozy idle 2D è lo strumento più adatto. Unity sarebbe overkill, gli altri hanno comunità più piccole o limitazioni.
- **Conseguenze attese:** Risparmio di 100-150 ore di sviluppo rispetto a C# in Unity, comunità in crescita per supporto.

### Decisione #002 - Target piattaforma: Android prima, iOS dopo
- **Data:** Maggio 2026
- **Decisione:** Sviluppare e pubblicare prima per Android, valutare iOS solo se Android funziona
- **Alternative considerate:** iOS prima (più monetizzante), entrambi insieme
- **Motivazione:** Android costa 25$ una tantum vs 99$/anno di iOS. Sviluppatore ha già un Mac quindi iOS resta possibile, ma per validare l'idea Android basta e avanza. Strategia "validare prima di investire".
- **Conseguenze attese:** Time-to-market più veloce, costi iniziali contenuti.

### Decisione #003 - Stile visivo v1: 2D piatto cottagecore (NO isometrico)
- **Data:** Maggio 2026
- **Decisione:** v1.0 sarà 2D piatto vista frontale stile Window Garden, isometrico rimandato a v2.0
- **Alternative considerate:** Isometrico fin dall'inizio (stile Animal Crossing Pocket Camp)
- **Motivazione:** Isometrico richiede 10-14 mesi part-time, 2D piatto 6-8 mesi. Validare l'idea prima con qualcosa di pubblicabile. Lo sviluppatore non ha esperienza gamedev né di pixel/illustration art isometrica.
- **Conseguenze attese:** Pubblicazione possibile entro 8-12 mesi. Se gioco ha successo, v2.0 isometrica con eventuali entrate generate.

### Decisione #004 - Stack di collaborazione AI
- **Data:** Maggio 2026
- **Decisione:** Claude per codice/pianificazione/architettura, ChatGPT per generazione immagini
- **Alternative considerate:** Solo ChatGPT, solo Claude, altri tool AI specializzati
- **Motivazione:** Sviluppatore ha già accesso a entrambi. Divisione di responsabilità chiara sfrutta i punti di forza di ciascuno.
- **Conseguenze attese:** Workflow chiaro, no overlap, ottimizzazione del tempo.

### Decisione #005 - Repository: GitHub pubblico con CODEMAP
- **Data:** Maggio 2026
- **Decisione:** Usare GitHub fin dalla Milestone 1 con file CODEMAP.md come indice
- **Alternative considerate:** Backup manuale locale, GitHub privato, altri host (GitLab, Bitbucket)
- **Motivazione:** GitHub pubblico permette a Claude di leggere i file via web_fetch. Versioning gratuito, backup, portfolio futuro. CODEMAP riduce token consumati per orientamento.
- **Conseguenze attese:** Workflow di collaborazione AI più efficiente, codice sempre backuppato.

---

## TEMPLATE PER NUOVE DECISIONI (copia qui sotto)

### Decisione #XXX - Titolo breve
- **Data:** 
- **Decisione:** 
- **Alternative considerate:** 
- **Motivazione:** 
- **Conseguenze attese:** 

---

**Ultimo aggiornamento:** Maggio 2026, Milestone 0 completata
