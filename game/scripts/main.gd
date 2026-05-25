extends Node2D

# ============================================================
# MILESTONE 1 STEP 2 - Giardino con tipi di pianta
# ============================================================
# Il giardino ora istanzia 3 piante di TIPI DIVERSI, caricando
# i dati da file .tres in res://data/piante/.
# Salvataggio: bump a versione 2, ora ogni pianta salva anche
# il suo id_pianta per ricaricare il tipo corretto.
# ============================================================

const TEMPO_CRESCITA_AUTO: float = 1.0
const FILE_SALVATAGGIO: String = "user://salvataggio.save"
const VERSIONE_SALVATAGGIO: int = 2

const PIANTA_SCENA: PackedScene = preload("res://scenes/pianta.tscn")

# --- DATABASE PIANTE ---
# Tutti i tipi caricati a startup. Per aggiungere una pianta:
# 1. Crea il .tres in res://data/piante/
# 2. Aggiungilo qui sotto
# 3. (Se vuoi che appaia nel giardino di default, aggiungilo a PIANTE_INIZIALI)
const TUTTI_I_DATI: Dictionary = {
	"pothos": preload("res://data/piante/pothos.tres"),
	"sansevieria": preload("res://data/piante/sansevieria.tres"),
	"monstera": preload("res://data/piante/monstera.tres"),
}

# Quali piante mostrare al primo avvio (slot 0, slot 1, slot 2).
# In M1 Step 3 (shop) questa lista non sarà più fissa: sarà il
# giocatore a decidere cosa mettere in ogni slot.
const PIANTE_INIZIALI: Array[String] = ["pothos", "sansevieria", "monstera"]

# --- STATO GLOBALE ---
var semi: int = 0
var piante: Array[Pianta] = []

# --- RIFERIMENTI NODI ---
@onready var contenitore_piante: HBoxContainer = $UI/ContenitorePiante
@onready var label_semi: Label = $UI/LabelSemi
@onready var timer_crescita: Timer = $TimerCrescita


func _ready() -> void:
	# 1. Istanzia le piante secondo PIANTE_INIZIALI
	for id_pianta in PIANTE_INIZIALI:
		istanzia_pianta(id_pianta)
	
	# 2. Carica salvataggio (sovrascrive stato e, se necessario, i tipi)
	carica_dati()
	
	# 3. Avvia tick di crescita passiva
	timer_crescita.wait_time = TEMPO_CRESCITA_AUTO
	timer_crescita.timeout.connect(_su_timer_crescita)
	timer_crescita.start()
	
	aggiorna_ui()


# Crea una pianta del tipo richiesto e la aggiunge al contenitore.
# IMPORTANTE: chiama imposta_dati() PRIMA di add_child, così quando
# parte _ready() della pianta i dati sono già disponibili.
func istanzia_pianta(id_pianta: String) -> Pianta:
	if not TUTTI_I_DATI.has(id_pianta):
		push_error("Tipo di pianta sconosciuto: %s" % id_pianta)
		return null
	
	var p: Pianta = PIANTA_SCENA.instantiate()
	p.imposta_dati(TUTTI_I_DATI[id_pianta])
	contenitore_piante.add_child(p)
	p.raccolta_effettuata.connect(_su_raccolta_effettuata)
	p.stato_cambiato.connect(_su_stato_cambiato)
	piante.append(p)
	return p


# ============================================================
# EVENTI DALLE PIANTE
# ============================================================

func _su_raccolta_effettuata(quantita: int) -> void:
	semi += quantita
	aggiorna_ui()


func _su_stato_cambiato() -> void:
	salva_dati()


# ============================================================
# CRESCITA PASSIVA
# ============================================================

func _su_timer_crescita() -> void:
	for p in piante:
		p.applica_crescita_passiva(TEMPO_CRESCITA_AUTO)
	salva_dati()


# ============================================================
# UI
# ============================================================

func aggiorna_ui() -> void:
	label_semi.text = "🌱 Semi: %d" % semi


# ============================================================
# SALVATAGGIO v2
# ============================================================
# Formato:
# {
#   "versione": 2,
#   "semi": int,
#   "timestamp": float,
#   "piante": [
#     {"id_pianta": "pothos", "acqua_attuale": 30.0, "matura": false},
#     ...
#   ]
# }
# I save M1.1 (versione 1) vengono scartati: avevano piante senza tipo.
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
	
	# Solo save v2 sono compatibili (decisione: partiamo puliti)
	if int(dati.get("versione", 0)) != VERSIONE_SALVATAGGIO:
		return
	
	semi = int(dati.get("semi", 0))
	
	var stati_salvati: Array = dati.get("piante", [])
	
	# Per ogni slot, ricarico lo stato.
	# Caso speciale: se l'id_pianta salvato è diverso da quello
	# istanziato (perché in futuro il giocatore avrà cambiato pianta
	# in quello slot), distruggo la pianta attuale e ne creo una del
	# tipo salvato. Per Step 2 in pratica non capita mai (PIANTE_INIZIALI
	# è fissa), ma il codice è pronto per Step 3.
	for i in stati_salvati.size():
		var stato: Dictionary = stati_salvati[i]
		var id_salvato: String = stato.get("id_pianta", "")
		
		if id_salvato == "" or not TUTTI_I_DATI.has(id_salvato):
			continue  # save corrotto, salta
		
		if i < piante.size():
			# Slot esistente: stesso tipo? aggiorna stato. Tipo diverso? sostituisci.
			if piante[i].dati.id_pianta == id_salvato:
				piante[i].carica_stato(stato)
			else:
				sostituisci_pianta(i, id_salvato, stato)
		else:
			# Nel save c'era una pianta in più che non abbiamo istanziato di default
			var nuova: Pianta = istanzia_pianta(id_salvato)
			if nuova != null:
				nuova.carica_stato(stato)
	
	# Crescita offline
	var timestamp_salvato: float = dati.get("timestamp", Time.get_unix_time_from_system())
	var secondi_offline: float = Time.get_unix_time_from_system() - timestamp_salvato
	if secondi_offline > 0:
		for p in piante:
			p.applica_crescita_passiva(secondi_offline)


# Sostituisce la pianta nello slot indicato con una di tipo diverso.
# Utile quando il save contiene un tipo diverso da quello di default.
func sostituisci_pianta(indice: int, id_nuovo: String, stato: Dictionary) -> void:
	var vecchia: Pianta = piante[indice]
	vecchia.queue_free()
	
	var nuova: Pianta = PIANTA_SCENA.instantiate()
	nuova.imposta_dati(TUTTI_I_DATI[id_nuovo])
	# Inseriamo nello stesso punto del contenitore
	contenitore_piante.add_child(nuova)
	contenitore_piante.move_child(nuova, indice)
	nuova.raccolta_effettuata.connect(_su_raccolta_effettuata)
	nuova.stato_cambiato.connect(_su_stato_cambiato)
	piante[indice] = nuova
	nuova.carica_stato(stato)


# Salva anche quando l'app perde focus o viene chiusa
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		salva_dati()
