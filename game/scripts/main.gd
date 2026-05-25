extends Node2D

# ============================================================
# MILESTONE 1 STEP 3 - Giardino con shop e vasi vuoti
# ============================================================
# Il giardino non possiede più lo stato: tutto vive in
# ProgressoGiocatore (singleton). Il giardino è una "vista":
# legge lo stato e mostra le scene appropriate (Pianta o
# VasoVuoto) in ogni slot.
#
# Quando il giocatore torna dallo shop, il _ready() viene
# rieseguito e il giardino si ricostruisce dallo stato attuale.
# ============================================================

const TEMPO_CRESCITA_AUTO: float = 1.0

const PIANTA_SCENA: PackedScene = preload("res://scenes/pianta.tscn")
const VASO_VUOTO_SCENA: PackedScene = preload("res://scenes/vaso_vuoto.tscn")

# Lista in-memory dei nodi attualmente nel giardino (mix di Pianta e VasoVuoto)
var nodi_slot: Array = []

@onready var contenitore_piante: GridContainer = $UI/Scroll/ContenitorePiante
@onready var label_semi: Label = $UI/Header/LabelSemi
@onready var pulsante_shop: Button = $UI/PulsanteShop
@onready var timer_crescita: Timer = $TimerCrescita


func _ready() -> void:
	# Ascolto i cambiamenti dei semi (anche quelli fatti dallo shop
	# o da altre fonti future)
	ProgressoGiocatore.semi_cambiati.connect(_su_semi_cambiati)
	pulsante_shop.pressed.connect(_su_shop_premuto)
	
	# Costruisci il giardino dallo stato attuale del singleton
	ricostruisci_giardino()
	
	# Tick di crescita passiva
	timer_crescita.wait_time = TEMPO_CRESCITA_AUTO
	timer_crescita.timeout.connect(_su_timer_crescita)
	timer_crescita.start()
	
	aggiorna_label_semi()


# Distrugge tutti i nodi attuali e ricostruisce in base al singleton.
# Chiamata in _ready() e dopo "pianta nel vaso".
func ricostruisci_giardino() -> void:
	for n in nodi_slot:
		n.queue_free()
	nodi_slot.clear()
	
	for i in ProgressoGiocatore.slot_piante.size():
		var stato: Dictionary = ProgressoGiocatore.slot_piante[i]
		var id_p: String = stato.get("id_pianta", "")
		
		if id_p == "" or not ProgressoGiocatore.TUTTI_I_DATI.has(id_p):
			# Slot vuoto
			var vv: VasoVuoto = VASO_VUOTO_SCENA.instantiate()
			contenitore_piante.add_child(vv)
			# Catturiamo l'indice nel callback (closure)
			var indice_locale: int = i
			vv.click_pianta_qui.connect(func(): _su_click_vaso_vuoto(indice_locale))
			nodi_slot.append(vv)
		else:
			# Pianta vera
			var dati: DatiPianta = ProgressoGiocatore.TUTTI_I_DATI[id_p]
			var p: Pianta = PIANTA_SCENA.instantiate()
			p.imposta(dati, i, stato)
			contenitore_piante.add_child(p)
			p.raccolta_effettuata.connect(_su_raccolta.bind(i))
			p.stato_cambiato.connect(_su_stato_cambiato.bind(i))
			nodi_slot.append(p)


# ============================================================
# EVENTI DALLE PIANTE
# ============================================================

func _su_raccolta(quantita: int, _indice: int) -> void:
	ProgressoGiocatore.aggiungi_semi(quantita)
	# Non serve salvare qui: stato_cambiato arriva subito dopo


func _su_stato_cambiato(indice: int) -> void:
	# Aggiorna lo stato dello slot nel singleton e salva
	var nodo = nodi_slot[indice]
	if nodo is Pianta:
		ProgressoGiocatore.aggiorna_stato_slot(indice, nodo.ottieni_stato())
	ProgressoGiocatore.salva()


func _su_semi_cambiati(_nuovi: int) -> void:
	aggiorna_label_semi()


# ============================================================
# CRESCITA PASSIVA
# ============================================================

func _su_timer_crescita() -> void:
	for n in nodi_slot:
		if n is Pianta:
			n.applica_crescita_passiva(TEMPO_CRESCITA_AUTO)
	# Aggiorna gli stati nel singleton e salva una sola volta
	for i in nodi_slot.size():
		if nodi_slot[i] is Pianta:
			ProgressoGiocatore.aggiorna_stato_slot(i, nodi_slot[i].ottieni_stato())
	ProgressoGiocatore.salva()


# ============================================================
# VASO VUOTO -> SCELTA TIPO
# ============================================================

func _su_click_vaso_vuoto(indice_slot: int) -> void:
	var sbloccate: Array[String] = ProgressoGiocatore.lista_piante_sbloccate()
	if sbloccate.is_empty():
		return
	
	# Mostra un PopupMenu con i tipi sbloccati
	var menu: PopupMenu = PopupMenu.new()
	for i in sbloccate.size():
		var id: String = sbloccate[i]
		var dati: DatiPianta = ProgressoGiocatore.TUTTI_I_DATI[id]
		menu.add_item(dati.nome_visualizzato, i)
	
	add_child(menu)
	menu.id_pressed.connect(func(scelta_id: int):
		var id_scelto: String = sbloccate[scelta_id]
		if ProgressoGiocatore.pianta_nello_slot(indice_slot, id_scelto):
			ricostruisci_giardino()
		menu.queue_free()
	)
	# Posiziona il menu vicino al puntatore
	menu.position = Vector2i(get_viewport().get_mouse_position())
	menu.popup()


# ============================================================
# SHOP
# ============================================================

func _su_shop_premuto() -> void:
	# Salva prima di cambiare scena (sicurezza)
	ProgressoGiocatore.salva()
	get_tree().change_scene_to_file("res://scenes/shop.tscn")


# ============================================================
# UI
# ============================================================

func aggiorna_label_semi() -> void:
	label_semi.text = "🌱 Semi: %d" % ProgressoGiocatore.semi


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Il salvataggio è già gestito da ProgressoGiocatore,
		# ma non guasta forzarlo qui
		ProgressoGiocatore.salva()
