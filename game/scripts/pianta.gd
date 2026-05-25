extends Control
class_name Pianta

# ============================================================
# MILESTONE 1 STEP 3 - Pianta connessa al singleton progresso
# ============================================================
# Rispetto a Step 2:
# - La pianta sa il suo indice_slot per persistere lo stato
#   direttamente nel singleton ProgressoGiocatore.
# - I segnali "raccolta_effettuata" e "stato_cambiato" restano,
#   ma il giardino li usa solo per UI/salvataggio.
# ============================================================

signal raccolta_effettuata(quantita_semi: int)
signal stato_cambiato

var dati: DatiPianta
var indice_slot: int = -1

var acqua_attuale: float = 0.0
var matura: bool = false

@onready var sprite: ColorRect = $Sprite
@onready var barra: ProgressBar = $Barra
@onready var pulsante_annaffia: Button = $PulsanteAnnaffia
@onready var pulsante_raccogli: Button = $PulsanteRaccogli
@onready var label_nome: Label = $LabelNome


# Il giardino DEVE chiamare questa prima di add_child()
func imposta(d: DatiPianta, slot: int, stato: Dictionary) -> void:
	dati = d
	indice_slot = slot
	acqua_attuale = stato.get("acqua_attuale", 0.0)
	matura = stato.get("matura", false)
	# Sicurezza
	if dati != null and acqua_attuale >= dati.acqua_per_crescita:
		acqua_attuale = dati.acqua_per_crescita
		matura = true


func _ready() -> void:
	if dati == null:
		push_error("Pianta istanziata senza imposta()!")
		return
	pulsante_annaffia.pressed.connect(_su_annaffia_premuto)
	pulsante_raccogli.pressed.connect(_su_raccogli_premuto)
	barra.max_value = dati.acqua_per_crescita
	label_nome.text = dati.nome_visualizzato
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
	aggiungi_acqua(secondi * dati.acqua_passiva_al_secondo, false)


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
		sprite.color = dati.colore_base.lerp(dati.colore_maturo, progresso * 0.5)
		sprite.scale = Vector2(0.6 + progresso * 0.6, 0.6 + progresso * 0.6)
