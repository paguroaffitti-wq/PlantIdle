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
# - Piante sbloccate (set di id)
# - Numero di vasi disponibili
# - Contenuto di ogni slot (id_pianta + stato di crescita)
#
# Gestisce anche il salvataggio su file.
# ============================================================

const FILE_SALVATAGGIO: String = "user://salvataggio.save"
const VERSIONE_SALVATAGGIO: int = 3

# Tutti i tipi di pianta esistenti nel gioco.
# Stesso dizionario usato da main.gd, ma ora ufficialmente vive qui.
const TUTTI_I_DATI: Dictionary = {
	"pothos": preload("res://data/piante/pothos.tres"),
	"sansevieria": preload("res://data/piante/sansevieria.tres"),
	"monstera": preload("res://data/piante/monstera.tres"),
}

# Costi dei vasi aggiuntivi. L'indice è "il numero di vaso a cui
# si vuole arrivare" - es. costi_vasi[3] = costo per arrivare a 4 vasi.
# Indici 0/1/2/3 (i primi 3 vasi) sono inutilizzati ma li teniamo per
# leggibilità dell'array.
const COSTI_VASI: Array[int] = [0, 0, 0, 50, 150, 400]
const MAX_VASI: int = 6

# Tipo iniziale dato gratis al giocatore
const TIPO_INIZIALE: String = "pothos"


# --- STATO ---
var semi: int = 0
# Set di id_pianta sbloccati. Usiamo Dictionary come set (chiavi = id).
var piante_sbloccate: Dictionary = {}
var numero_vasi: int = 3
# Contenuto degli slot. Ogni elemento è un Dictionary:
#   { "id_pianta": "pothos", "acqua_attuale": 30.0, "matura": false }
# oppure { "id_pianta": "" } per vaso vuoto.
var slot_piante: Array = []

# Segnali per chi vuole reagire ai cambiamenti (es. UI dello shop
# che aggiorna i prezzi quando i semi cambiano)
signal semi_cambiati(nuovi_semi: int)
signal pianta_sbloccata(id_pianta: String)
signal vaso_aggiunto(nuovo_totale: int)


func _ready() -> void:
	carica()


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
	salva()
	semi_cambiati.emit(semi)
	pianta_sbloccata.emit(id_pianta)
	return true


func puoi_comprare_vaso() -> bool:
	if numero_vasi >= MAX_VASI:
		return false
	return semi >= costo_prossimo_vaso()


func costo_prossimo_vaso() -> int:
	# Costo del vaso (numero_vasi + 1)esimo
	var indice_prossimo: int = numero_vasi  # se ho 3 vasi, voglio costo per arrivare a 4
	if indice_prossimo >= COSTI_VASI.size():
		return 999999  # max raggiunto
	return COSTI_VASI[indice_prossimo]


func compra_vaso() -> bool:
	if not puoi_comprare_vaso():
		return false
	semi -= costo_prossimo_vaso()
	numero_vasi += 1
	# Aggiungi uno slot vuoto in fondo
	slot_piante.append({"id_pianta": ""})
	salva()
	semi_cambiati.emit(semi)
	vaso_aggiunto.emit(numero_vasi)
	return true


# ============================================================
# API GIARDINO
# ============================================================

# Chiamata dal giardino quando una pianta produce semi
func aggiungi_semi(quantita: int) -> void:
	semi += quantita
	semi_cambiati.emit(semi)
	# Non salviamo qui: il giardino chiama salva() dopo aver
	# aggiornato anche lo stato delle piante (un solo write).


# Pianta un tipo già sbloccato in uno slot vuoto. Gratis.
func pianta_nello_slot(indice_slot: int, id_pianta: String) -> bool:
	if indice_slot < 0 or indice_slot >= slot_piante.size():
		return false
	if not piante_sbloccate.has(id_pianta):
		return false
	if slot_piante[indice_slot].get("id_pianta", "") != "":
		return false  # slot occupato
	slot_piante[indice_slot] = {
		"id_pianta": id_pianta,
		"acqua_attuale": 0.0,
		"matura": false,
	}
	salva()
	return true


# Aggiorna lo stato della pianta in uno slot (chiamato dal giardino
# per persistere acqua/maturazione).
func aggiorna_stato_slot(indice_slot: int, stato: Dictionary) -> void:
	if indice_slot < 0 or indice_slot >= slot_piante.size():
		return
	slot_piante[indice_slot] = stato


# Restituisce la lista degli id sbloccati come Array (più comodo per UI)
func lista_piante_sbloccate() -> Array[String]:
	var risultato: Array[String] = []
	for id in piante_sbloccate.keys():
		risultato.append(id)
	return risultato


# ============================================================
# SALVATAGGIO v3
# ============================================================
# Formato:
# {
#   "versione": 3,
#   "semi": int,
#   "timestamp": float,
#   "piante_sbloccate": ["pothos", ...],
#   "numero_vasi": int,
#   "slot_piante": [ {id_pianta, acqua_attuale, matura}, ... ]
# }
# ============================================================

func salva() -> void:
	var dati: Dictionary = {
		"versione": VERSIONE_SALVATAGGIO,
		"semi": semi,
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
	
	# Solo save v3 sono compatibili (decisione: partiamo puliti)
	if int(dati.get("versione", 0)) != VERSIONE_SALVATAGGIO:
		_inizializza_nuovo_giocatore()
		return
	
	semi = int(dati.get("semi", 0))
	numero_vasi = int(dati.get("numero_vasi", 3))
	
	# Ricostruisci il set delle piante sbloccate
	piante_sbloccate = {}
	for id in dati.get("piante_sbloccate", []):
		if TUTTI_I_DATI.has(id):
			piante_sbloccate[id] = true
	
	# Slot piante (validati: id sconosciuti -> slot vuoto)
	slot_piante = []
	var slot_salvati: Array = dati.get("slot_piante", [])
	for s in slot_salvati:
		var id_p: String = s.get("id_pianta", "")
		if id_p == "" or TUTTI_I_DATI.has(id_p):
			slot_piante.append(s)
		else:
			slot_piante.append({"id_pianta": ""})
	
	# Garantisce coerenza: numero_vasi == slot_piante.size()
	while slot_piante.size() < numero_vasi:
		slot_piante.append({"id_pianta": ""})
	while slot_piante.size() > numero_vasi:
		slot_piante.pop_back()
	
	# Crescita offline: applica il tempo trascorso alle piante non mature
	var timestamp_salvato: float = dati.get("timestamp", Time.get_unix_time_from_system())
	var secondi_offline: float = Time.get_unix_time_from_system() - timestamp_salvato
	if secondi_offline > 0:
		_applica_crescita_offline(secondi_offline)


func _inizializza_nuovo_giocatore() -> void:
	semi = 0
	numero_vasi = 3
	piante_sbloccate = {TIPO_INIZIALE: true}
	# Slot 0 = Pothos già piantata, slot 1-2 vuoti
	slot_piante = [
		{"id_pianta": TIPO_INIZIALE, "acqua_attuale": 0.0, "matura": false},
		{"id_pianta": ""},
		{"id_pianta": ""},
	]
	salva()


# Crescita offline: per ogni pianta nei vasi, aggiungi acqua passiva
# in base al tempo trascorso. Implementata qui perché il calcolo
# avviene PRIMA che il giardino istanzi i nodi.
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
