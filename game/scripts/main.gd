extends Node2D

# ============================================================
# M2 Step 3: aggiunto pulsante missioni + registra_raccolta()
# ============================================================

const TEMPO_CRESCITA_AUTO: float = 1.0

const PIANTA_SCENA: PackedScene = preload("res://scenes/pianta.tscn")
const VASO_VUOTO_SCENA: PackedScene = preload("res://scenes/vaso_vuoto.tscn")

var nodi_slot: Array = []

@onready var contenitore_piante: GridContainer = $UI/Scroll/ContenitorePiante
@onready var label_semi: Label = $UI/Header/LabelSemi
@onready var label_livello: Label = $UI/Header/LabelLivello
@onready var barra_xp: ProgressBar = $UI/Header/BarraXP
@onready var pulsante_shop: Button = $UI/PulsanteShop
@onready var pulsante_missioni: Button = $UI/PulsanteMissioni
@onready var timer_crescita: Timer = $TimerCrescita


func _ready() -> void:
	ProgressoGiocatore.semi_cambiati.connect(_su_semi_cambiati)
	ProgressoGiocatore.livello_cambiato.connect(_su_livello_cambiato)
	ProgressoGiocatore.xp_cambiato.connect(_su_xp_cambiato)
	ProgressoGiocatore.missioni_aggiornate.connect(_su_missioni_aggiornate)
	pulsante_shop.pressed.connect(_su_shop_premuto)
	pulsante_missioni.pressed.connect(_su_missioni_premuto)

	ricostruisci_giardino()

	timer_crescita.wait_time = TEMPO_CRESCITA_AUTO
	timer_crescita.timeout.connect(_su_timer_crescita)
	timer_crescita.start()

	aggiorna_label_semi()
	aggiorna_ui_livello()
	aggiorna_badge_missioni()


func ricostruisci_giardino() -> void:
	for n in nodi_slot:
		n.queue_free()
	nodi_slot.clear()

	for i in ProgressoGiocatore.slot_piante.size():
		var stato: Dictionary = ProgressoGiocatore.slot_piante[i]
		var id_p: String = stato.get("id_pianta", "")

		if id_p == "" or not ProgressoGiocatore.TUTTI_I_DATI.has(id_p):
			var vv: VasoVuoto = VASO_VUOTO_SCENA.instantiate()
			contenitore_piante.add_child(vv)
			var indice_locale: int = i
			vv.click_pianta_qui.connect(func(): _su_click_vaso_vuoto(indice_locale))
			nodi_slot.append(vv)
		else:
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
	ProgressoGiocatore.registra_raccolta()


func _su_stato_cambiato(indice: int) -> void:
	var nodo = nodi_slot[indice]
	if nodo is Pianta:
		ProgressoGiocatore.aggiorna_stato_slot(indice, nodo.ottieni_stato())
	ProgressoGiocatore.salva()


func _su_semi_cambiati(_nuovi: int) -> void:
	aggiorna_label_semi()


# ============================================================
# LIVELLO
# ============================================================

func _su_livello_cambiato(_nuovo: int) -> void:
	aggiorna_ui_livello()
	_anima_level_up()


func _su_xp_cambiato(xp: int, xp_necessari: int) -> void:
	barra_xp.max_value = xp_necessari
	barra_xp.value = xp


func aggiorna_ui_livello() -> void:
	var lv: int = ProgressoGiocatore.livello
	var xp: int = ProgressoGiocatore.xp_attuale
	var xp_max: int = ProgressoGiocatore.xp_per_prossimo_livello()
	if lv >= ProgressoGiocatore.LIVELLO_MAX:
		label_livello.text = "Lv. %d  ✨" % lv
	else:
		label_livello.text = "Lv. %d" % lv
	barra_xp.max_value = xp_max
	barra_xp.value = xp


func _anima_level_up() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(label_livello, "scale", Vector2(1.4, 1.4), 0.15)
	tween.tween_property(label_livello, "scale", Vector2(1.0, 1.0), 0.20)
	label_livello.add_theme_color_override("font_color", Color(0.95, 0.80, 0.20, 1))
	await get_tree().create_timer(0.5).timeout
	label_livello.remove_theme_color_override("font_color")


# ============================================================
# MISSIONI
# ============================================================

func _su_missioni_aggiornate() -> void:
	aggiorna_badge_missioni()


# Mostra un pallino arancione sul pulsante se ci sono missioni
# completate ma non ancora ritirate.
func aggiorna_badge_missioni() -> void:
	var ha_premi: bool = false
	for m in ProgressoGiocatore.missioni_oggi:
		if m.get("completata", false) and not m.get("ritirata", false):
			ha_premi = true
			break
	if ha_premi:
		pulsante_missioni.text = "📋 Missioni  🔴"
	else:
		pulsante_missioni.text = "📋 Missioni"


# ============================================================
# CRESCITA PASSIVA
# ============================================================

func _su_timer_crescita() -> void:
	for n in nodi_slot:
		if n is Pianta:
			n.applica_crescita_passiva(TEMPO_CRESCITA_AUTO)
	for i in nodi_slot.size():
		if nodi_slot[i] is Pianta:
			ProgressoGiocatore.aggiorna_stato_slot(i, nodi_slot[i].ottieni_stato())
	ProgressoGiocatore.salva()


# ============================================================
# VASO VUOTO
# ============================================================

func _su_click_vaso_vuoto(indice_slot: int) -> void:
	var sbloccate: Array[String] = ProgressoGiocatore.lista_piante_sbloccate()
	if sbloccate.is_empty():
		return
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
	menu.position = Vector2i(get_viewport().get_mouse_position())
	menu.popup()


# ============================================================
# NAVIGAZIONE
# ============================================================

func _su_shop_premuto() -> void:
	ProgressoGiocatore.salva()
	get_tree().change_scene_to_file("res://scenes/shop.tscn")


func _su_missioni_premuto() -> void:
	ProgressoGiocatore.salva()
	get_tree().change_scene_to_file("res://scenes/missioni.tscn")


# ============================================================
# UI
# ============================================================

func aggiorna_label_semi() -> void:
	label_semi.text = "🌱 Semi: %d" % ProgressoGiocatore.semi


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		ProgressoGiocatore.salva()
