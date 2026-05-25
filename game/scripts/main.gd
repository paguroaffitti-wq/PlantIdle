extends Node2D

# ============================================================
# MILESTONE 1 - Giardino multi-pianta
# ============================================================
# La scena principale ora gestisce N piante in una griglia.
# Ogni pianta è un componente autonomo (vedi pianta.gd) e
# comunica col giardino tramite segnali.
#
# Responsabilità del giardino:
# - Istanziare le piante negli slot
# - Ascoltare i loro segnali (raccolta -> +semi)
# - Gestire i semi globali del giocatore
# - Salvare/caricare lo stato dell'intero giardino
# - Distribuire la crescita passiva (timer condiviso)
# ============================================================

const NUMERO_PIANTE: int = 3
const TEMPO_CRESCITA_AUTO: float = 1.0  # tick ogni secondo
const FILE_SALVATAGGIO: String = "user://salvataggio.save"
const VERSIONE_SALVATAGGIO: int = 1  # serve per migrazioni future

# Carichiamo la scena Pianta come risorsa: la istanzieremo N volte.
const PIANTA_SCENA: PackedScene = preload("res://scenes/pianta.tscn")

# --- STATO GLOBALE ---
var semi: int = 0
var piante: Array[Pianta] = []  # tipato: array di nodi Pianta

# --- RIFERIMENTI NODI ---
@onready var contenitore_piante: HBoxContainer = $UI/ContenitorePiante
@onready var label_semi: Label = $UI/LabelSemi
@onready var timer_crescita: Timer = $TimerCrescita


func _ready() -> void:
	# 1. Istanzia le piante negli slot
	for i in NUMERO_PIANTE:
		var p: Pianta = PIANTA_SCENA.instantiate()
		contenitore_piante.add_child(p)
		# Ascolta i segnali della pianta. Usa bind(i) se in futuro
		# servirà sapere "quale" pianta ha emesso (per ora non serve).
		p.raccolta_effettuata.connect(_su_raccolta_effettuata)
		p.stato_cambiato.connect(_su_stato_cambiato)
		piante.append(p)
	
	# 2. Carica il salvataggio (popola semi e stato piante)
	carica_dati()
	
	# 3. Avvia il tick di crescita passiva
	timer_crescita.wait_time = TEMPO_CRESCITA_AUTO
	timer_crescita.timeout.connect(_su_timer_crescita)
	timer_crescita.start()
	
	aggiorna_ui()


# ============================================================
# GESTIONE EVENTI DALLE PIANTE
# ============================================================

func _su_raccolta_effettuata(quantita: int) -> void:
	semi += quantita
	aggiorna_ui()
	# Il segnale stato_cambiato della pianta arriverà subito dopo
	# e farà partire il salvataggio. Niente doppio salvataggio qui.


func _su_stato_cambiato() -> void:
	salva_dati()


# ============================================================
# CRESCITA PASSIVA (cuore della meccanica idle)
# ============================================================

func _su_timer_crescita() -> void:
	for p in piante:
		p.applica_crescita_passiva(TEMPO_CRESCITA_AUTO)
	# Salviamo ogni secondo per non perdere progressi.
	# In M2 potremmo ridurre frequenza (ogni 5-10s) se troppo intenso.
	salva_dati()


# ============================================================
# UI
# ============================================================

func aggiorna_ui() -> void:
	label_semi.text = "🌱 Semi: %d" % semi


# ============================================================
# SALVATAGGIO
# ============================================================
# Nuovo formato (M1):
# {
#   "versione": 1,
#   "semi": int,
#   "timestamp": float,
#   "piante": [ {acqua_attuale, matura}, ... ]
# }
# Il vecchio formato M0 viene ignorato (decisione: partiamo puliti)
# ============================================================

func salva_dati() -> void:
	var stati_piante: Array = []
	for p in piante:
		stati_piante.append(p.ottieni_stato())
	
	var dati: Dictionary = {
		"versione": VERSIONE_SALVATAGGIO,
		"semi": semi,
		"timestamp": Time.get_unix_time_from_system(),
		"piante": stati_piante,
	}
	
	var file: FileAccess = FileAccess.open(FILE_SALVATAGGIO, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(dati))
		file.close()


func carica_dati() -> void:
	if not FileAccess.file_exists(FILE_SALVATAGGIO):
		return
	
	var file: FileAccess = FileAccess.open(FILE_SALVATAGGIO, FileAccess.READ)
	if not file:
		return
	var contenuto: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	if json.parse(contenuto) != OK:
		return
	var dati = json.data
	if typeof(dati) != TYPE_DICTIONARY:
		return
	
	# Controllo versione: se manca "versione" è un vecchio save M0,
	# lo scartiamo (decisione: partiamo puliti).
	if not dati.has("versione"):
		return
	
	semi = int(dati.get("semi", 0))
	
	# Ricarica stato piante. Se il numero salvato non combacia con
	# NUMERO_PIANTE attuale (es. domani aumenti gli slot), le piante
	# extra restano vuote.
	var stati_salvati: Array = dati.get("piante", [])
	for i in piante.size():
		if i < stati_salvati.size():
			piante[i].carica_stato(stati_salvati[i])
	
	# Crescita offline: applica il tempo trascorso a TUTTE le piante.
	var timestamp_salvato: float = dati.get("timestamp", Time.get_unix_time_from_system())
	var secondi_offline: float = Time.get_unix_time_from_system() - timestamp_salvato
	if secondi_offline > 0:
		for p in piante:
			p.applica_crescita_passiva(secondi_offline)


# Salva anche quando l'app perde focus o viene chiusa
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		salva_dati()
