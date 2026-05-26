extends Node2D

# ============================================================
# SCHERMATA MISSIONI GIORNALIERE
# ============================================================
# Mostra le 3 missioni del giorno con progresso e pulsante
# "Ritira" per riscuotere la ricompensa quando completate.
# ============================================================

const MAIN_SCENA: String = "res://main.tscn"

@onready var label_semi: Label = $UI/Header/LabelSemi
@onready var label_reset: Label = $UI/Header/LabelReset
@onready var contenitore: VBoxContainer = $UI/Scroll/Contenitore
@onready var pulsante_indietro: Button = $UI/PulsanteIndietro


func _ready() -> void:
	pulsante_indietro.pressed.connect(_su_indietro_premuto)
	ProgressoGiocatore.missioni_aggiornate.connect(_ricostruisci)
	ProgressoGiocatore.semi_cambiati.connect(_su_semi_cambiati)
	aggiorna_label_semi()
	aggiorna_label_reset()
	_ricostruisci()


func _ricostruisci() -> void:
	for figlio in contenitore.get_children():
		figlio.queue_free()
	for i in ProgressoGiocatore.missioni_oggi.size():
		contenitore.add_child(_crea_card_missione(i))


func _crea_card_missione(indice: int) -> Control:
	var m: Dictionary = ProgressoGiocatore.missioni_oggi[indice]
	var completata: bool = m.get("completata", false)
	var ritirata: bool = m.get("ritirata", false)
	var progresso: int = m.get("progresso", 0)
	var target: int = m.get("target", 1)
	var ricompensa: int = m.get("ricompensa_semi", 0)

	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 120)

	var stile: StyleBoxFlat = StyleBoxFlat.new()
	if ritirata:
		stile.bg_color = Color(0.85, 0.88, 0.82, 1)   # verde pallido — completata
	elif completata:
		stile.bg_color = Color(0.98, 0.95, 0.80, 1)   # giallo caldo — pronta da ritirare
	else:
		stile.bg_color = Color(0.96, 0.94, 0.89, 1)   # crema — in corso
	stile.corner_radius_top_left = 12
	stile.corner_radius_top_right = 12
	stile.corner_radius_bottom_right = 12
	stile.corner_radius_bottom_left = 12
	stile.border_width_bottom = 3
	stile.border_color = Color(0.70, 0.65, 0.55, 0.5)
	stile.content_margin_left = 16.0
	stile.content_margin_top = 12.0
	stile.content_margin_right = 16.0
	stile.content_margin_bottom = 12.0
	card.add_theme_stylebox_override("panel", stile)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	# Riga superiore: icona stato + descrizione
	var riga_top: HBoxContainer = HBoxContainer.new()
	vbox.add_child(riga_top)

	var icona: Label = Label.new()
	if ritirata:
		icona.text = "✅ "
	elif completata:
		icona.text = "🌟 "
	else:
		icona.text = "📌 "
	icona.add_theme_font_size_override("font_size", 20)
	riga_top.add_child(icona)

	var desc: Label = Label.new()
	desc.text = m.get("descrizione", "")
	desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 17)
	desc.add_theme_color_override("font_color", Color(0.22, 0.20, 0.16, 1))
	riga_top.add_child(desc)

	# Barra progresso
	var barra: ProgressBar = ProgressBar.new()
	barra.max_value = target
	barra.value = progresso
	barra.show_percentage = false
	barra.custom_minimum_size = Vector2(0, 14)
	vbox.add_child(barra)

	# Riga inferiore: testo progresso + pulsante ritira
	var riga_bot: HBoxContainer = HBoxContainer.new()
	vbox.add_child(riga_bot)

	var label_prog: Label = Label.new()
	if ritirata:
		label_prog.text = "Completata! ✨"
		label_prog.add_theme_color_override("font_color", Color(0.30, 0.50, 0.25, 1))
	else:
		label_prog.text = "%d / %d" % [progresso, target]
		label_prog.add_theme_color_override("font_color", Color(0.40, 0.37, 0.30, 1))
	label_prog.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_prog.add_theme_font_size_override("font_size", 15)
	riga_bot.add_child(label_prog)

	var pulsante: Button = Button.new()
	if ritirata:
		pulsante.text = "Ritirata"
		pulsante.disabled = true
	elif completata:
		pulsante.text = "Ritira 🌱%d" % ricompensa
		pulsante.disabled = false
		var idx: int = indice  # cattura per closure
		pulsante.pressed.connect(func():
			ProgressoGiocatore.ritira_missione(idx)
		)
	else:
		pulsante.text = "In corso..."
		pulsante.disabled = true
	pulsante.add_theme_font_size_override("font_size", 15)
	riga_bot.add_child(pulsante)

	return card


func aggiorna_label_semi() -> void:
	label_semi.text = "🌱 Semi: %d" % ProgressoGiocatore.semi


func aggiorna_label_reset() -> void:
	# Calcola i secondi al prossimo reset (mezzanotte UTC)
	var ora_unix: float = Time.get_unix_time_from_system()
	var secondi_nel_giorno: int = int(ora_unix) % 86400
	var secondi_al_reset: int = 86400 - secondi_nel_giorno
	var ore: int = secondi_al_reset / 3600
	var minuti: int = (secondi_al_reset % 3600) / 60
	label_reset.text = "Reset tra %dh %02dm" % [ore, minuti]


func _su_semi_cambiati(_nuovi: int) -> void:
	aggiorna_label_semi()


func _su_indietro_premuto() -> void:
	get_tree().change_scene_to_file(MAIN_SCENA)
