extends Control
class_name Pianta

# ============================================================
# MILESTONE 1 STEP 2 - Pianta data-driven
# ============================================================
# La pianta non ha più costanti hardcoded: legge tutto dalla
# risorsa `dati` (DatiPianta) che il giardino le passa prima
# di aggiungerla all'albero.
# ============================================================

# --- SEGNALI VERSO IL GIARDINO ---
signal raccolta_effettuata(quantita_semi: int)
signal stato_cambiato

# --- DATI DEL TIPO (assegnati dal giardino prima di _ready) ---
var dati: DatiPianta

# --- STATO ---
var acqua_attuale: float = 0.0
var matura: bool = false

# --- RIFERIMENTI NODI ---
@onready var sprite: ColorRect = $Sprite
@onready var barra: ProgressBar = $Barra
@onready var pulsante_annaffia: Button = $PulsanteAnnaffia
@onready var pulsante_raccogli: Button = $PulsanteRaccogli
@onready var label_nome: Label = $LabelNome


# ============================================================
# API PUBBLICA (chiamata dal giardino)
# ============================================================

# Il giardino DEVE chiamare questa prima di add_child().
# In questo modo, quando arriva _ready(), dati è già disponibile.
func imposta_dati(d: DatiPianta) -> void:
	dati = d


func _ready() -> void:
	# Sanity check: se dati non è stato passato, ci accorgiamo subito
	if dati == null:
		push_error("Pianta istanziata senza chiamare imposta_dati()!")
		return
	
	pulsante_annaffia.pressed.connect(_su_annaffia_premuto)
	pulsante_raccogli.pressed.connect(_su_raccogli_premuto)
	barra.max_value = dati.acqua_per_crescita
	label_nome.text = dati.nome_visualizzato
	aggiorna_visuale()


func carica_stato(stato: Dictionary) -> void:
	acqua_attuale = stato.get("acqua_attuale", 0.0)
	matura = stato.get("matura", false)
	if dati != null and acqua_attuale >= dati.acqua_per_crescita:
		acqua_attuale = dati.acqua_per_crescita
		matura = true
	if is_node_ready():
		aggiorna_visuale()


func ottieni_stato() -> Dictionary:
	return {
		"id_pianta": dati.id_pianta,
		"acqua_attuale": acqua_attuale,
		"matura": matura,
	}


func applica_crescita_passiva(secondi: float) -> void:
	if matura or dati == null:
		return
	var acqua_da_aggiungere: float = secondi * dati.acqua_passiva_al_secondo
	aggiungi_acqua(acqua_da_aggiungere, false)


# ============================================================
# LOGICA INTERNA
# ============================================================

func _su_annaffia_premuto() -> void:
	if matura:
		return
	aggiungi_acqua(dati.acqua_per_tap, true)


func _su_raccogli_premuto() -> void:
	if not matura:
		return
	matura = false
	acqua_attuale = 0.0
	aggiorna_visuale()
	raccolta_effettuata.emit(dati.semi_per_raccolto)
	stato_cambiato.emit()


func aggiungi_acqua(quantita: float, emetti_segnale: bool) -> void:
	if matura:
		return
	acqua_attuale += quantita
	if acqua_attuale >= dati.acqua_per_crescita:
		acqua_attuale = dati.acqua_per_crescita
		matura = true
	aggiorna_visuale()
	if emetti_segnale:
		stato_cambiato.emit()


func aggiorna_visuale() -> void:
	if dati == null:
		return
	
	barra.value = acqua_attuale
	
	if matura:
		pulsante_raccogli.disabled = false
		pulsante_annaffia.disabled = true
		sprite.color = dati.colore_maturo
		sprite.scale = Vector2(1.3, 1.3)
	else:
		pulsante_raccogli.disabled = true
		pulsante_annaffia.disabled = false
		var progresso: float = acqua_attuale / dati.acqua_per_crescita
		# Interpolazione: la pianta sfuma dal colore_base verso una versione
		# più chiara man mano che cresce
		sprite.color = dati.colore_base.lerp(dati.colore_maturo, progresso * 0.5)
		sprite.scale = Vector2(0.6 + progresso * 0.6, 0.6 + progresso * 0.6)
