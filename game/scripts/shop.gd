extends Node2D

# ============================================================
# SHOP - Scena dedicata
# ============================================================
# Mostra:
# - Semi disponibili (in cima)
# - Lista piante NON ancora sbloccate (con costo)
# - Pulsante "compra vaso" se sotto il limite
# - Pulsante "indietro" per tornare al giardino
#
# Tutti gli acquisti passano per ProgressoGiocatore, che è la
# unica fonte di verità sui semi/sblocchi/vasi.
# ============================================================

const MAIN_SCENA: String = "res://main.tscn"

@onready var label_semi: Label = $UI/LabelSemi
@onready var lista_piante: VBoxContainer = $UI/Scroll/ListaPiante
@onready var pulsante_compra_vaso: Button = $UI/PulsanteCompraVaso
@onready var label_vasi: Label = $UI/LabelVasi
@onready var pulsante_indietro: Button = $UI/PulsanteIndietro


func _ready() -> void:
	pulsante_indietro.pressed.connect(_su_indietro_premuto)
	pulsante_compra_vaso.pressed.connect(_su_compra_vaso_premuto)
	
	# Reagisci ai cambiamenti per ridisegnare la UI
	ProgressoGiocatore.semi_cambiati.connect(_su_semi_cambiati)
	ProgressoGiocatore.pianta_sbloccata.connect(_su_pianta_sbloccata)
	ProgressoGiocatore.vaso_aggiunto.connect(_su_vaso_aggiunto)
	
	aggiorna_tutto()


func aggiorna_tutto() -> void:
	label_semi.text = "🌱 Semi: %d" % ProgressoGiocatore.semi
	aggiorna_lista_piante()
	aggiorna_sezione_vasi()


func aggiorna_lista_piante() -> void:
	# Pulisci la lista
	for figlio in lista_piante.get_children():
		figlio.queue_free()
	
	# Genera una "card" per ogni pianta NON sbloccata
	for id in ProgressoGiocatore.TUTTI_I_DATI.keys():
		if ProgressoGiocatore.piante_sbloccate.has(id):
			continue
		var dati: DatiPianta = ProgressoGiocatore.TUTTI_I_DATI[id]
		lista_piante.add_child(crea_card_pianta(dati))


# Crea una "card" per la pianta: nome, descrizione, costo, pulsante.
# Costruita interamente da codice per non avere una sotto-scena
# (riusabilità non necessaria, sta solo qui).
func crea_card_pianta(dati: DatiPianta) -> Control:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 120)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)
	
	var nome: Label = Label.new()
	nome.text = dati.nome_visualizzato
	nome.add_theme_font_size_override("font_size", 22)
	vbox.add_child(nome)
	
	var desc: Label = Label.new()
	desc.text = dati.descrizione
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc)
	
	var riga: HBoxContainer = HBoxContainer.new()
	vbox.add_child(riga)
	
	var prezzo: Label = Label.new()
	prezzo.text = "🌱 %d" % dati.costo_sblocco
	prezzo.add_theme_font_size_override("font_size", 18)
	prezzo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(prezzo)
	
	var pulsante: Button = Button.new()
	pulsante.text = "Sblocca"
	pulsante.add_theme_font_size_override("font_size", 18)
	pulsante.disabled = not ProgressoGiocatore.puoi_sbloccare_pianta(dati.id_pianta)
	pulsante.pressed.connect(func(): ProgressoGiocatore.sblocca_pianta(dati.id_pianta))
	riga.add_child(pulsante)
	
	return card


func aggiorna_sezione_vasi() -> void:
	var vasi: int = ProgressoGiocatore.numero_vasi
	var max_vasi: int = ProgressoGiocatore.MAX_VASI
	
	if vasi >= max_vasi:
		label_vasi.text = "Vasi: %d / %d (massimo raggiunto)" % [vasi, max_vasi]
		pulsante_compra_vaso.disabled = true
		pulsante_compra_vaso.text = "Tutto pieno 🪴"
		return
	
	var costo: int = ProgressoGiocatore.costo_prossimo_vaso()
	label_vasi.text = "Vasi: %d / %d" % [vasi, max_vasi]
	pulsante_compra_vaso.text = "Compra vaso (🌱 %d)" % costo
	pulsante_compra_vaso.disabled = not ProgressoGiocatore.puoi_comprare_vaso()


# ============================================================
# AZIONI
# ============================================================

func _su_indietro_premuto() -> void:
	get_tree().change_scene_to_file(MAIN_SCENA)


func _su_compra_vaso_premuto() -> void:
	ProgressoGiocatore.compra_vaso()


# ============================================================
# REAZIONI AI SEGNALI DEL SINGLETON
# ============================================================

func _su_semi_cambiati(_nuovi: int) -> void:
	# Ridisegna tutto (i pulsanti potrebbero cambiare disabled status)
	aggiorna_tutto()


func _su_pianta_sbloccata(_id: String) -> void:
	aggiorna_lista_piante()


func _su_vaso_aggiunto(_n: int) -> void:
	aggiorna_sezione_vasi()
