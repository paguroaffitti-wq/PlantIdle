extends Node

# ============================================================
# AUTOLOAD: PROGRESSO GIOCATORE
# ============================================================
# Singleton che mantiene lo stato del giocatore tra le scene.
# Accessibile da qualsiasi script come `ProgressoGiocatore` se
# registrato come Autoload (vedi project.godot).
#
# Cosa contiene:
# - Semi posseduti
# - Livello e XP (M2 Step 2)
# - Piante sbloccate (set di id)
# - Numero di vasi disponibili
# - Contenuto di ogni slot (id_pianta + stato di crescita)
#
# Gestisce anche il salvataggio su file.
# ============================================================

const FILE_SALVATAGGIO: String = "user://salvataggio.save"
const VERSIONE_SALVATAGGIO: int = 4  # bump: aggiunto livello/xp

# Tutti i tipi di pianta esistenti nel gioco.
const TUTTI_I_DATI: Dictionary = {
	"pothos":      preload("res://data/piante/pothos.tres"),
	"sansevieria": preload("res://data/piante/sansevieria.tres"),
	"monstera":    preload("res://data/piante/monstera.tres"),
	"pachira":     preload("res://data/piante/pachira.tres"),
	"calathea":    preload("res://data/piante/calathea.tres"),
	"pilea":       preload("res://data/piante/pilea.tres"),
	"aloe":        preload("res://data/piante/aloe.tres"),
	"cactus":      preload("res://data/piante/cactus.tres"),
}

const COSTI_VASI: Array[int] = [0, 0, 0, 50, 150, 400]
const MAX_VASI: int = 6
const TIPO_INIZIALE: String = "pothos"

# Livello massimo raggiungibile in M2
const LIVELLO_MAX: int = 20

# XP fissi per azioni non legate alla raccolta
const XP_SBLOCCO_PIANTA: int = 20
const XP_ACQUISTO_VASO: int = 15


# --- STATO ---
var semi: int = 0
var livello: int = 1
var xp_attuale: int = 0
var piante_sbloccate: Dictionary = {}
var numero_vasi: int = 3
var slot_piante: Array = []

# Segnali
signal semi_cambiati(nuovi_semi: int)
signal pianta_sbloccata(id_pianta: String)
signal vaso_aggiunto(nuovo_totale: int)
signal livello_cambiato(nuovo_livello: int)
signal xp_cambiato(xp: int, xp_necessari: int)


func _ready() -> void:
	carica()


# ============================================================
# SISTEMA LIVELLI (M2 Step 2)
# ============================================================

# XP necessari per salire AL livello successivo.
# Curva: 100 * livello^1.4 — cresce progressivamente.
func xp_per_prossimo_livello() -> int:
	return int(100.0 * pow(livello, 1.4))


# Aggiunge XP e gestisce eventuali level-up (anche multipli).
func aggiungi_xp(quantita: int) -> void:
	if livello >= LIVELLO_MAX:
		return
	xp_attuale += quantita
	var level_up: bool = false
	while xp_attuale >= xp_per_prossimo_livello() and livello < LIVELLO_MAX:
		xp_attuale -= xp_per_prossimo_livello()
		livello += 1
		level_up = true
	if xp_attuale < 0:
		xp_attuale = 0
	xp_cambiato.emit(xp_attuale, xp_per_prossimo_livello())
	if level_up:
		livello_cambiato.emit(livello)


# ============================================================
# API SHOP
# ============================================================

func puoi_sbloccare_pianta(id_pianta: String) -> bool:
	if piante_sbloccate.has(id_pianta):
		return false
	if not TUTTI_I_DATI.has(id_pianta):
		return false
	var dati: DatiPianta = TUTTI_I_DATI[id_pianta]
	return semi >= dati.costo_sblocco


func sblocca_pianta(id_pianta: String) -> bool:
	if not puoi_sbloccare_pianta(id_pianta):
		return false
	var dati: DatiPianta = TUTTI_I_DATI[id_pianta]
	semi -= dati.costo_sblocco
	piante_sbloccate[id_pianta] = true
	aggiungi_xp(XP_SBLOCCO_PIANTA)
	salva()
	semi_cambiati.emit(semi)
	pianta_sbloccata.emit(id_pianta)
	return true


func puoi_comprare_vaso() -> bool:
	if numero_vasi >= MAX_VASI:
		return false
	return semi >= costo_prossimo_vaso()


func costo_prossimo_vaso() -> int:
	var indice_prossimo: int = numero_vasi
	if indice_prossimo >= COSTI_VASI.size():
		return 999999
	return COSTI_VASI[indice_prossimo]


func compra_vaso() -> bool:
	if not puoi_comprare_vaso():
		return false
	semi -= costo_prossimo_vaso()
	numero_vasi += 1
	slot_piante.append({"id_pianta": ""})
	aggiungi_xp(XP_ACQUISTO_VASO)
	salva()
	semi_cambiati.emit(semi)
	vaso_aggiunto.emit(numero_vasi)
	return true


# ============================================================
# API GIARDINO
# ============================================================

func aggiungi_semi(quantita: int) -> void:
	semi += quantita
	# XP dalla raccolta: 1 XP ogni 4 semi (minimo 1)
	var xp_guadagnati: int = max(1, quantita / 4)
	aggiungi_xp(xp_guadagnati)
	semi_cambiati.emit(semi)


func pianta_nello_slot(indice_slot: int, id_pianta: String) -> bool:
	if indice_slot < 0 or indice_slot >= slot_piante.size():
		return false
	if not piante_sbloccate.has(id_pianta):
		return false
	if slot_piante[indice_slot].get("id_pianta", "") != "":
		return false
	slot_piante[indice_slot] = {
		"id_pianta": id_pianta,
		"acqua_attuale": 0.0,
		"matura": false,
	}
	salva()
	return true


func aggiorna_stato_slot(indice_slot: int, stato: Dictionary) -> void:
	if indice_slot < 0 or indice_slot >= slot_piante.size():
		return
	slot_piante[indice_slot] = stato


func lista_piante_sbloccate() -> Array[String]:
	var risultato: Array[String] = []
	for id in piante_sbloccate.keys():
		risultato.append(id)
	return risultato


# ============================================================
# SALVATAGGIO v4
# ============================================================
# Aggiunto rispetto a v3: "livello" e "xp_attuale"
# ============================================================

func salva() -> void:
	var dati: Dictionary = {
		"versione": VERSIONE_SALVATAGGIO,
		"semi": semi,
		"livello": livello,
		"xp_attuale": xp_attuale,
		"timestamp": Time.get_unix_time_from_system(),
		"piante_sbloccate": piante_sbloccate.keys(),
		"numero_vasi": numero_vasi,
		"slot_piante": slot_piante,
	}
	var file: FileAccess = FileAccess.open(FILE_SALVATAGGIO, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(dati))
		file.close()


func carica() -> void:
	if not FileAccess.file_exists(FILE_SALVATAGGIO):
		_inizializza_nuovo_giocatore()
		return

	var file: FileAccess = FileAccess.open(FILE_SALVATAGGIO, FileAccess.READ)
	if not file:
		_inizializza_nuovo_giocatore()
		return
	var contenuto: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	if json.parse(contenuto) != OK:
		_inizializza_nuovo_giocatore()
		return
	var dati = json.data
	if typeof(dati) != TYPE_DICTIONARY:
		_inizializza_nuovo_giocatore()
		return

	if int(dati.get("versione", 0)) != VERSIONE_SALVATAGGIO:
		_inizializza_nuovo_giocatore()
		return

	semi = int(dati.get("semi", 0))
	livello = int(dati.get("livello", 1))
	xp_attuale = int(dati.get("xp_attuale", 0))
	numero_vasi = int(dati.get("numero_vasi", 3))

	piante_sbloccate = {}
	for id in dati.get("piante_sbloccate", []):
		if TUTTI_I_DATI.has(id):
			piante_sbloccate[id] = true

	slot_piante = []
	var slot_salvati: Array = dati.get("slot_piante", [])
	for s in slot_salvati:
		var id_p: String = s.get("id_pianta", "")
		if id_p == "" or TUTTI_I_DATI.has(id_p):
			slot_piante.append(s)
		else:
			slot_piante.append({"id_pianta": ""})

	while slot_piante.size() < numero_vasi:
		slot_piante.append({"id_pianta": ""})
	while slot_piante.size() > numero_vasi:
		slot_piante.pop_back()

	var timestamp_salvato: float = dati.get("timestamp", Time.get_unix_time_from_system())
	var secondi_offline: float = Time.get_unix_time_from_system() - timestamp_salvato
	if secondi_offline > 0:
		_applica_crescita_offline(secondi_offline)


func _inizializza_nuovo_giocatore() -> void:
	semi = 0
	livello = 1
	xp_attuale = 0
	numero_vasi = 3
	piante_sbloccate = {TIPO_INIZIALE: true}
	slot_piante = [
		{"id_pianta": TIPO_INIZIALE, "acqua_attuale": 0.0, "matura": false},
		{"id_pianta": ""},
		{"id_pianta": ""},
	]
	salva()


func _applica_crescita_offline(secondi: float) -> void:
	for i in slot_piante.size():
		var s: Dictionary = slot_piante[i]
		var id_p: String = s.get("id_pianta", "")
		if id_p == "":
			continue
		var matura: bool = s.get("matura", false)
		if matura:
			continue
		var dati: DatiPianta = TUTTI_I_DATI[id_p]
		var acqua: float = s.get("acqua_attuale", 0.0)
		acqua += secondi * dati.acqua_passiva_al_secondo
		if acqua >= dati.acqua_per_crescita:
			acqua = dati.acqua_per_crescita
			s["matura"] = true
		s["acqua_attuale"] = acqua
		slot_piante[i] = s


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		salva()
