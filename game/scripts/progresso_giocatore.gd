extends Node

# ============================================================
# AUTOLOAD: PROGRESSO GIOCATORE — save v7
# ============================================================

const FILE_SALVATAGGIO: String = "user://salvataggio.save"
const VERSIONE_SALVATAGGIO: int = 7

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
const LIVELLO_MAX: int = 20
const XP_SBLOCCO_PIANTA: int = 20
const XP_ACQUISTO_VASO: int = 15

const POOL_MISSIONI: Array = [
	{"id": "annaffia_5",       "tipo": "annaffia",      "target": 5,   "ricompensa_semi": 15, "descrizione": "Annaffia le piante 5 volte"},
	{"id": "annaffia_10",      "tipo": "annaffia",      "target": 10,  "ricompensa_semi": 25, "descrizione": "Annaffia le piante 10 volte"},
	{"id": "annaffia_20",      "tipo": "annaffia",      "target": 20,  "ricompensa_semi": 40, "descrizione": "Annaffia le piante 20 volte"},
	{"id": "raccogli_1",       "tipo": "raccogli",      "target": 1,   "ricompensa_semi": 15, "descrizione": "Raccogli 1 pianta matura"},
	{"id": "raccogli_3",       "tipo": "raccogli",      "target": 3,   "ricompensa_semi": 25, "descrizione": "Raccogli 3 piante mature"},
	{"id": "raccogli_5",       "tipo": "raccogli",      "target": 5,   "ricompensa_semi": 40, "descrizione": "Raccogli 5 piante mature"},
	{"id": "guadagna_semi_20", "tipo": "guadagna_semi", "target": 20,  "ricompensa_semi": 15, "descrizione": "Guadagna 20 semi oggi"},
	{"id": "guadagna_semi_50", "tipo": "guadagna_semi", "target": 50,  "ricompensa_semi": 25, "descrizione": "Guadagna 50 semi oggi"},
	{"id": "guadagna_semi_100","tipo": "guadagna_semi", "target": 100, "ricompensa_semi": 40, "descrizione": "Guadagna 100 semi oggi"},
]

const MISSIONI_PER_GIORNO: int = 3

var semi: int = 0
var livello: int = 1
var xp_attuale: int = 0
var piante_sbloccate: Dictionary = {}
var numero_vasi: int = 3
var slot_piante: Array = []
var missioni_oggi: Array = []
var missioni_giorno: int = 0
var semi_oggi: int = 0

signal semi_cambiati(nuovi_semi: int)
signal pianta_sbloccata(id_pianta: String)
signal vaso_aggiunto(nuovo_totale: int)
signal livello_cambiato(nuovo_livello: int)
signal xp_cambiato(xp: int, xp_necessari: int)
signal missioni_aggiornate()


func _ready() -> void:
	carica()


func xp_per_prossimo_livello() -> int:
	return int(100.0 * pow(livello, 1.4))


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


func _giorno_attuale() -> int:
	return int(Time.get_unix_time_from_system() / 86400)


func controlla_reset_missioni() -> void:
	if _giorno_attuale() != missioni_giorno:
		_reset_missioni(_giorno_attuale())


func _reset_missioni(giorno: int) -> void:
	missioni_giorno = giorno
	semi_oggi = 0
	missioni_oggi = []
	var pool_copia: Array = POOL_MISSIONI.duplicate()
	pool_copia.shuffle()
	for i in MISSIONI_PER_GIORNO:
		var m: Dictionary = pool_copia[i].duplicate()
		m["progresso"] = 0
		m["completata"] = false
		m["ritirata"] = false
		missioni_oggi.append(m)
	salva()
	missioni_aggiornate.emit()


func _avanza_missioni(tipo: String, quantita: int) -> void:
	var cambio: bool = false
	for m in missioni_oggi:
		if m["tipo"] == tipo and not m["completata"]:
			m["progresso"] = min(m["progresso"] + quantita, m["target"])
			if m["progresso"] >= m["target"]:
				m["completata"] = true
			cambio = true
	if cambio:
		missioni_aggiornate.emit()


func ritira_missione(indice: int) -> bool:
	if indice < 0 or indice >= missioni_oggi.size():
		return false
	var m: Dictionary = missioni_oggi[indice]
	if not m["completata"] or m["ritirata"]:
		return false
	m["ritirata"] = true
	semi += m["ricompensa_semi"]
	aggiungi_xp(m["ricompensa_semi"] / 2)
	salva()
	semi_cambiati.emit(semi)
	missioni_aggiornate.emit()
	return true


func puoi_sbloccare_pianta(id_pianta: String) -> bool:
	if piante_sbloccate.has(id_pianta):
		return false
	if not TUTTI_I_DATI.has(id_pianta):
		return false
	return semi >= TUTTI_I_DATI[id_pianta].costo_sblocco


func sblocca_pianta(id_pianta: String) -> bool:
	if not puoi_sbloccare_pianta(id_pianta):
		return false
	semi -= TUTTI_I_DATI[id_pianta].costo_sblocco
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
	var idx: int = numero_vasi
	if idx >= COSTI_VASI.size():
		return 999999
	return COSTI_VASI[idx]


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


func aggiungi_semi(quantita: int) -> void:
	semi += quantita
	semi_oggi += quantita
	aggiungi_xp(max(1, quantita / 4))
	semi_cambiati.emit(semi)
	_avanza_missioni("guadagna_semi", quantita)


func registra_annaffiatura() -> void:
	_avanza_missioni("annaffia", 1)


func registra_raccolta() -> void:
	_avanza_missioni("raccogli", 1)


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
		"raccolte_cumulative": 0,
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
		"missioni_giorno": missioni_giorno,
		"missioni_oggi": missioni_oggi,
		"semi_oggi": semi_oggi,
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
	missioni_giorno = int(dati.get("missioni_giorno", 0))
	semi_oggi = int(dati.get("semi_oggi", 0))

	piante_sbloccate = {}
	for id in dati.get("piante_sbloccate", []):
		if TUTTI_I_DATI.has(id):
			piante_sbloccate[id] = true

	slot_piante = []
	for s in dati.get("slot_piante", []):
		var id_p: String = s.get("id_pianta", "")
		if id_p == "" or TUTTI_I_DATI.has(id_p):
			slot_piante.append(s)
		else:
			slot_piante.append({"id_pianta": ""})

	while slot_piante.size() < numero_vasi:
		slot_piante.append({"id_pianta": ""})
	while slot_piante.size() > numero_vasi:
		slot_piante.pop_back()

	missioni_oggi = []
	for m in dati.get("missioni_oggi", []):
		missioni_oggi.append(m)

	controlla_reset_missioni()

	var ts: float = dati.get("timestamp", Time.get_unix_time_from_system())
	var offline: float = Time.get_unix_time_from_system() - ts
	if offline > 0:
		_applica_crescita_offline(offline)


func _inizializza_nuovo_giocatore() -> void:
	semi = 0
	livello = 1
	xp_attuale = 0
	numero_vasi = 3
	piante_sbloccate = {TIPO_INIZIALE: true}
	slot_piante = [
		{"id_pianta": TIPO_INIZIALE, "acqua_attuale": 0.0, "matura": false, "raccolte_cumulative": 0},
		{"id_pianta": ""},
		{"id_pianta": ""},
	]
	missioni_oggi = []
	missioni_giorno = 0
	semi_oggi = 0
	_reset_missioni(_giorno_attuale())
	salva()


func _applica_crescita_offline(secondi: float) -> void:
	for i in slot_piante.size():
		var s: Dictionary = slot_piante[i]
		var id_p: String = s.get("id_pianta", "")
		if id_p == "" or s.get("matura", false):
			continue
		var d: DatiPianta = TUTTI_I_DATI[id_p]
		var acqua: float = s.get("acqua_attuale", 0.0)
		acqua += secondi * d.acqua_passiva_al_secondo
		if acqua >= d.acqua_per_crescita:
			acqua = d.acqua_per_crescita
			s["matura"] = true
		s["acqua_attuale"] = acqua
		slot_piante[i] = s


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		salva()
