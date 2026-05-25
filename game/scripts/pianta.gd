extends Control
class_name Pianta

# ============================================================
# MILESTONE 1 - Componente Pianta riutilizzabile
# ============================================================
# Una pianta autonoma con la sua acqua, il suo stadio di
# crescita e i suoi pulsanti. Non sa nulla del giardino:
# comunica con l'esterno tramite SEGNALI.
# Il giardino ascolta i segnali e gestisce semi/salvataggio.
# ============================================================

# --- COSTANTI DI BILANCIAMENTO ---
# NOTA: in M1 step 2 queste diventeranno parametri per tipo
# di pianta (pothos lento, pachira veloce, ecc.) caricati da
# dati_piante.gd. Per ora restano costanti uguali per tutti.
const ACQUA_PER_CRESCITA: float = 100.0
const ACQUA_PER_TAP: float = 5.0
const SEMI_PER_RACCOLTO: int = 10
const ACQUA_PASSIVA: float = 1.0  # acqua/secondo crescita passiva

# --- SEGNALI VERSO IL GIARDINO ---
# Il giardino si iscrive a questi segnali per sapere cosa succede.
signal raccolta_effettuata(quantita_semi: int)
signal stato_cambiato  # generico: triggera un salvataggio

# --- STATO ---
var acqua_attuale: float = 0.0
var matura: bool = false

# --- RIFERIMENTI NODI ---
# I path sono relativi alla scena pianta.tscn
@onready var sprite: ColorRect = $Sprite
@onready var barra: ProgressBar = $Barra
@onready var pulsante_annaffia: Button = $PulsanteAnnaffia
@onready var pulsante_raccogli: Button = $PulsanteRaccogli


func _ready() -> void:
	pulsante_annaffia.pressed.connect(_su_annaffia_premuto)
	pulsante_raccogli.pressed.connect(_su_raccogli_premuto)
	barra.max_value = ACQUA_PER_CRESCITA
	aggiorna_visuale()


# ============================================================
# API PUBBLICA (chiamata dal giardino)
# ============================================================

# Carica lo stato della pianta (es. dopo caricamento salvataggio)
func carica_stato(dati: Dictionary) -> void:
	acqua_attuale = dati.get("acqua_attuale", 0.0)
	matura = dati.get("matura", false)
	# Se ha più acqua della soglia, è matura (sicurezza)
	if acqua_attuale >= ACQUA_PER_CRESCITA:
		acqua_attuale = ACQUA_PER_CRESCITA
		matura = true
	if is_node_ready():
		aggiorna_visuale()


# Restituisce lo stato della pianta per il salvataggio
func ottieni_stato() -> Dictionary:
	return {
		"acqua_attuale": acqua_attuale,
		"matura": matura,
	}


# Applica crescita passiva (chiamata dal giardino ogni secondo
# e anche al caricamento per recuperare il tempo offline)
func applica_crescita_passiva(secondi: float) -> void:
	if matura:
		return
	var acqua_da_aggiungere: float = secondi * ACQUA_PASSIVA
	aggiungi_acqua(acqua_da_aggiungere, false)  # niente segnale qui, lo emette il giardino


# ============================================================
# LOGICA INTERNA
# ============================================================

func _su_annaffia_premuto() -> void:
	if matura:
		return
	aggiungi_acqua(ACQUA_PER_TAP, true)


func _su_raccogli_premuto() -> void:
	if not matura:
		return
	# Resetta la pianta e notifica il giardino
	matura = false
	acqua_attuale = 0.0
	aggiorna_visuale()
	raccolta_effettuata.emit(SEMI_PER_RACCOLTO)
	stato_cambiato.emit()


func aggiungi_acqua(quantita: float, emetti_segnale: bool) -> void:
	if matura:
		return
	acqua_attuale += quantita
	if acqua_attuale >= ACQUA_PER_CRESCITA:
		acqua_attuale = ACQUA_PER_CRESCITA
		matura = true
	aggiorna_visuale()
	if emetti_segnale:
		stato_cambiato.emit()


func aggiorna_visuale() -> void:
	barra.value = acqua_attuale
	if matura:
		pulsante_raccogli.disabled = false
		pulsante_annaffia.disabled = true
		sprite.color = Color(0.2, 0.7, 0.2)
		sprite.scale = Vector2(1.3, 1.3)
	else:
		pulsante_raccogli.disabled = true
		pulsante_annaffia.disabled = false
		var progresso: float = acqua_attuale / ACQUA_PER_CRESCITA
		sprite.color = Color(0.4 + progresso * 0.3, 0.5 + progresso * 0.2, 0.3)
		sprite.scale = Vector2(0.6 + progresso * 0.6, 0.6 + progresso * 0.6)
