extends Node2D

# ============================================================
# MILESTONE 0 - "Una pianta che cresce"
# ============================================================
# Questo è il cuore logico del gioco. Tutta la meccanica base
# vive qui. Più avanti lo divideremo in file separati, ma per
# ora teniamo tutto insieme per chiarezza.
# ============================================================

# --- COSTANTI DI GIOCO (qui si bilanciano i numeri) ---
const ACQUA_PER_CRESCITA: float = 100.0  # quanta acqua serve per crescere del tutto
const ACQUA_PER_TAP: float = 5.0          # quanta acqua dà ogni tap del pulsante
const SEMI_PER_RACCOLTO: int = 10         # quanti semi produce una pianta matura
const TEMPO_CRESCITA_AUTO: float = 1.0    # ogni quanti secondi la pianta cresce da sola
const ACQUA_PASSIVA: float = 1.0          # quanta acqua si aggiunge ogni TEMPO_CRESCITA_AUTO

# --- STATO DEL GIOCO ---
var acqua_attuale: float = 0.0
var semi: int = 0
var pianta_matura: bool = false

# --- RIFERIMENTI AI NODI VISIVI ---
@onready var barra_crescita: ProgressBar = $UI/BarraCrescita
@onready var pulsante_annaffia: Button = $UI/PulsanteAnnaffia
@onready var pulsante_raccogli: Button = $UI/PulsanteRaccogli
@onready var label_semi: Label = $UI/LabelSemi
@onready var label_stato: Label = $UI/LabelStato
@onready var sprite_pianta: ColorRect = $Pianta
@onready var timer_crescita: Timer = $TimerCrescita

# --- PERCORSO FILE DI SALVATAGGIO ---
const FILE_SALVATAGGIO: String = "user://salvataggio.save"


func _ready() -> void:
	# Carica i dati salvati se esistono
	carica_dati()
	
	# Collega i segnali dei pulsanti alle funzioni
	pulsante_annaffia.pressed.connect(_su_annaffia_premuto)
	pulsante_raccogli.pressed.connect(_su_raccogli_premuto)
	
	# Configura il timer della crescita passiva
	timer_crescita.wait_time = TEMPO_CRESCITA_AUTO
	timer_crescita.timeout.connect(_su_timer_crescita)
	timer_crescita.start()
	
	aggiorna_ui()


func _su_annaffia_premuto() -> void:
	# Se la pianta è già matura, annaffiare non serve
	if pianta_matura:
		return
	
	aggiungi_acqua(ACQUA_PER_TAP)


func _su_raccogli_premuto() -> void:
	# Solo se la pianta è matura puoi raccogliere
	if not pianta_matura:
		return
	
	semi += SEMI_PER_RACCOLTO
	acqua_attuale = 0.0
	pianta_matura = false
	salva_dati()
	aggiorna_ui()


func _su_timer_crescita() -> void:
	# La pianta assorbe acqua "passivamente" anche senza tap
	# Questo è il cuore della meccanica "idle"
	if not pianta_matura:
		aggiungi_acqua(ACQUA_PASSIVA)
		# Salva ogni tot secondi così non si perde il progresso
		salva_dati()


func aggiungi_acqua(quantita: float) -> void:
	acqua_attuale += quantita
	
	if acqua_attuale >= ACQUA_PER_CRESCITA:
		acqua_attuale = ACQUA_PER_CRESCITA
		pianta_matura = true
	
	aggiorna_ui()


func aggiorna_ui() -> void:
	# Aggiorna barra di crescita
	barra_crescita.max_value = ACQUA_PER_CRESCITA
	barra_crescita.value = acqua_attuale
	
	# Aggiorna contatore semi
	label_semi.text = "🌱 Semi: %d" % semi
	
	# Aggiorna stato pianta
	if pianta_matura:
		label_stato.text = "Pianta matura! Raccogli!"
		pulsante_raccogli.disabled = false
		pulsante_annaffia.disabled = true
		# Pianta matura = colore più intenso e più grande
		sprite_pianta.color = Color(0.2, 0.7, 0.2)
		sprite_pianta.scale = Vector2(1.5, 1.5)
	else:
		label_stato.text = "Annaffia la pianta!"
		pulsante_raccogli.disabled = true
		pulsante_annaffia.disabled = false
		# Pianta che cresce: colore e dimensione proporzionali all'acqua
		var progresso: float = acqua_attuale / ACQUA_PER_CRESCITA
		sprite_pianta.color = Color(0.4 + progresso * 0.3, 0.5 + progresso * 0.2, 0.3)
		sprite_pianta.scale = Vector2(0.5 + progresso, 0.5 + progresso)


# ============================================================
# SISTEMA DI SALVATAGGIO
# ============================================================
# Su mobile è fondamentale: l'utente chiude l'app in qualsiasi
# momento. Salviamo su file JSON in user:// (cartella sicura
# gestita da Godot, diversa per ogni dispositivo).
# ============================================================

func salva_dati() -> void:
	var dati: Dictionary = {
		"acqua_attuale": acqua_attuale,
		"semi": semi,
		"pianta_matura": pianta_matura,
		"timestamp": Time.get_unix_time_from_system()
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
	var errore: int = json.parse(contenuto)
	if errore != OK:
		return
	
	var dati: Dictionary = json.data
	acqua_attuale = dati.get("acqua_attuale", 0.0)
	semi = dati.get("semi", 0)
	pianta_matura = dati.get("pianta_matura", false)
	
	# Calcolo crescita offline: se l'utente è stato via, simuliamo
	# la crescita passiva avvenuta nel frattempo. Questo è il
	# cuore dell'esperienza "idle"!
	var timestamp_salvato: float = dati.get("timestamp", Time.get_unix_time_from_system())
	var secondi_passati: float = Time.get_unix_time_from_system() - timestamp_salvato
	if secondi_passati > 0 and not pianta_matura:
		var acqua_offline: float = (secondi_passati / TEMPO_CRESCITA_AUTO) * ACQUA_PASSIVA
		aggiungi_acqua(acqua_offline)


# Salva anche quando l'app perde focus (utente preme home)
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		salva_dati()
