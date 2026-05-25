extends Node2D

# ============================================================
# SHOP - Step 4: card piante colorate, estetica cottagecore
# ============================================================

const MAIN_SCENA: String = "res://main.tscn"

@onready var label_semi: Label = $UI/Header/LabelSemi
@onready var lista_piante: VBoxContainer = $UI/Scroll/ListaPiante
@onready var pulsante_compra_vaso: Button = $UI/PulsanteCompraVaso
@onready var label_vasi: Label = $UI/LabelVasi
@onready var pulsante_indietro: Button = $UI/PulsanteIndietro


func _ready() -> void:
	pulsante_indietro.pressed.connect(_su_indietro_premuto)
	pulsante_compra_vaso.pressed.connect(_su_compra_vaso_premuto)
	ProgressoGiocatore.semi_cambiati.connect(_su_semi_cambiati)
	ProgressoGiocatore.pianta_sbloccata.connect(_su_pianta_sbloccata)
	ProgressoGiocatore.vaso_aggiunto.connect(_su_vaso_aggiunto)
	aggiorna_tutto()


func aggiorna_tutto() -> void:
	label_semi.text = "🌱 Semi: %d" % ProgressoGiocatore.semi
	aggiorna_lista_piante()
	aggiorna_sezione_vasi()


func aggiorna_lista_piante() -> void:
	for figlio in lista_piante.get_children():
		figlio.queue_free()
	for id in ProgressoGiocatore.TUTTI_I_DATI.keys():
		if ProgressoGiocatore.piante_sbloccate.has(id):
			continue
		var dati: DatiPianta = ProgressoGiocatore.TUTTI_I_DATI[id]
		lista_piante.add_child(crea_card_pianta(dati))


func crea_card_pianta(dati: DatiPianta) -> Control:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 110)

	# Sfondo della card colorato col colore base della pianta (schiarito)
	var stile: StyleBoxFlat = StyleBoxFlat.new()
	stile.bg_color = dati.colore_base.lightened(0.45)
	stile.corner_radius_top_left = 12
	stile.corner_radius_top_right = 12
	stile.corner_radius_bottom_right = 12
	stile.corner_radius_bottom_left = 12
	stile.border_width_bottom = 3
	stile.border_color = dati.colore_base.darkened(0.1)
	stile.content_margin_left = 14.0
	stile.content_margin_top = 10.0
	stile.content_margin_right = 14.0
	stile.content_margin_bottom = 10.0
	card.add_theme_stylebox_override("panel", stile)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	var nome: Label = Label.new()
	nome.text = dati.nome_visualizzato
	nome.add_theme_font_size_override("font_size", 20)
	nome.add_theme_color_override("font_color", dati.colore_maturo.darkened(0.3))
	vbox.add_child(nome)

	var desc: Label = Label.new()
	desc.text = dati.descrizione
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.25, 0.23, 0.19, 0.85))
	vbox.add_child(desc)

	var riga: HBoxContainer = HBoxContainer.new()
	vbox.add_child(riga)

	var prezzo: Label = Label.new()
	prezzo.text = "🌱 %d semi" % dati.costo_sblocco
	prezzo.add_theme_font_size_override("font_size", 17)
	prezzo.add_theme_color_override("font_color", Color(0.25, 0.45, 0.15, 1))
	prezzo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(prezzo)

	var pulsante: Button = Button.new()
	pulsante.text = "Sblocca"
	pulsante.add_theme_font_size_override("font_size", 17)
	pulsante.disabled = not ProgressoGiocatore.puoi_sbloccare_pianta(dati.id_pianta)
	pulsante.pressed.connect(func(): ProgressoGiocatore.sblocca_pianta(dati.id_pianta))
	riga.add_child(pulsante)

	return card


func aggiorna_sezione_vasi() -> void:
	var vasi: int = ProgressoGiocatore.numero_vasi
	var max_vasi: int = ProgressoGiocatore.MAX_VASI
	if vasi >= max_vasi:
		label_vasi.text = "Vasi: %d / %d  —  massimo raggiunto 🪴" % [vasi, max_vasi]
		pulsante_compra_vaso.disabled = true
		pulsante_compra_vaso.text = "Giardino completo 🌿"
		return
	var costo: int = ProgressoGiocatore.costo_prossimo_vaso()
	label_vasi.text = "Vasi attuali: %d / %d" % [vasi, max_vasi]
	pulsante_compra_vaso.text = "Aggiungi vaso  🌱 %d" % costo
	pulsante_compra_vaso.disabled = not ProgressoGiocatore.puoi_comprare_vaso()


func _su_indietro_premuto() -> void:
	get_tree().change_scene_to_file(MAIN_SCENA)


func _su_compra_vaso_premuto() -> void:
	ProgressoGiocatore.compra_vaso()


func _su_semi_cambiati(_nuovi: int) -> void:
	aggiorna_tutto()


func _su_pianta_sbloccata(_id: String) -> void:
	aggiorna_lista_piante()


func _su_vaso_aggiunto(_n: int) -> void:
	aggiorna_sezione_vasi()
