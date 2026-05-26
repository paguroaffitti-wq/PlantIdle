extends Control
class_name Pianta

# ============================================================
# M2 SPRITE — sistema livelli visivi + AnimatedSprite2D
# + indicatore livello pianta in alto a destra
# ============================================================

signal raccolta_effettuata(quantita_semi: int)
signal stato_cambiato

const SHEET_COLS: int = 10
const SHEET_FRAME_W: int = 192
const SHEET_FRAME_H: int = 192

var dati: DatiPianta
var indice_slot: int = -1
var acqua_attuale: float = 0.0
var matura: bool = false
var raccolte_cumulative: int = 0

var sprite_animato: AnimatedSprite2D = null

# Indicatore livello pianta (cerchio + numero) creato dinamicamente
var badge_livello: Control = null
var badge_label: Label = null

@onready var foglia_base: ColorRect = $Pianta/FogliaBase
@onready var foglia_secondaria: ColorRect = $Pianta/FogliaSecondaria
@onready var decorazione: ColorRect = $Pianta/Decorazione
@onready var contenitore_pianta: Control = $Pianta
@onready var barra: ProgressBar = $Barra
@onready var pulsante_annaffia: Button = $PulsanteAnnaffia
@onready var pulsante_raccogli: Button = $PulsanteRaccogli
@onready var label_nome: Label = $LabelNome


func imposta(d: DatiPianta, slot: int, stato: Dictionary) -> void:
	dati = d
	indice_slot = slot
	acqua_attuale = stato.get("acqua_attuale", 0.0)
	matura = stato.get("matura", false)
	raccolte_cumulative = stato.get("raccolte_cumulative", 0)
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
	# Decorazione vecchia non serve più: la nascondiamo definitivamente
	decorazione.visible = false
	_crea_badge_livello()
	_aggiorna_sprite()
	aggiorna_visuale()


func ottieni_stato() -> Dictionary:
	return {
		"id_pianta": dati.id_pianta,
		"acqua_attuale": acqua_attuale,
		"matura": matura,
		"raccolte_cumulative": raccolte_cumulative,
	}


func applica_crescita_passiva(secondi: float) -> void:
	if matura or dati == null:
		return
	aggiungi_acqua(secondi * dati.acqua_passiva_al_secondo, false)


# ============================================================
# BADGE LIVELLO (cerchio in alto a destra)
# ============================================================

func _crea_badge_livello() -> void:
	# Sfondo cerchio (Panel con StyleBoxFlat circolare)
	badge_livello = Panel.new()
	badge_livello.position = Vector2(178, 8)
	badge_livello.size = Vector2(34, 34)
	var stile: StyleBoxFlat = StyleBoxFlat.new()
	stile.bg_color = Color(0.55, 0.40, 0.25, 1)  # marrone terracotta
	stile.corner_radius_top_left = 17
	stile.corner_radius_top_right = 17
	stile.corner_radius_bottom_left = 17
	stile.corner_radius_bottom_right = 17
	stile.border_width_top = 2
	stile.border_width_bottom = 2
	stile.border_width_left = 2
	stile.border_width_right = 2
	stile.border_color = Color(0.97, 0.94, 0.88, 1)  # crema
	badge_livello.add_theme_stylebox_override("panel", stile)
	add_child(badge_livello)

	badge_label = Label.new()
	badge_label.position = Vector2(0, 0)
	badge_label.size = Vector2(34, 34)
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_label.add_theme_font_size_override("font_size", 18)
	badge_label.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88, 1))
	badge_livello.add_child(badge_label)
	_aggiorna_badge()


func _aggiorna_badge() -> void:
	if badge_label == null:
		return
	var lv: int = _livello_visivo_attuale() + 1  # 1-based per l'utente
	badge_label.text = str(lv)


# ============================================================
# SISTEMA SPRITE
# ============================================================

func _livello_visivo_attuale() -> int:
	return dati.livello_visivo(raccolte_cumulative)


# Restituisce lo sheet per il livello richiesto.
# Se non esiste, fa fallback al livello più alto disponibile.
# Così la pianta rimane visibile anche se mancano sheet futuri.
func _sheet_con_fallback(lv: int) -> Texture2D:
	# Prova il livello esatto
	var t: Texture2D = dati.spritesheet_per_livello(lv)
	if t != null:
		return t
	# Fallback: cerca il livello più alto disponibile <= lv
	for i in range(lv - 1, -1, -1):
		t = dati.spritesheet_per_livello(i)
		if t != null:
			return t
	return null


func _aggiorna_sprite() -> void:
	var lv: int = _livello_visivo_attuale()
	var texture: Texture2D = _sheet_con_fallback(lv)
	_aggiorna_badge()

	print("DEBUG pianta: lv=", lv, " texture=", texture, " raccolte_per_livello=", dati.raccolte_per_livello, " spritesheets=", dati.spritesheets)

	if texture == null:
		_rimuovi_sprite()
		_mostra_placeholder(true)
		return

	_mostra_placeholder(false)

	if sprite_animato == null:
		sprite_animato = AnimatedSprite2D.new()
		contenitore_pianta.add_child(sprite_animato)

	sprite_animato.position = Vector2(110, 75)
	sprite_animato.scale = Vector2(0.57, 0.57)

	var lv_sheet: int = _indice_sheet_per_texture(texture)
	_carica_frames(texture, lv_sheet)
	sprite_animato.play("idle")
	
	# DEBUG
	print("  sprite creato: pos=", sprite_animato.position, " scale=", sprite_animato.scale, " visible=", sprite_animato.visible, " modulate=", sprite_animato.modulate)
	print("  contenitore_pianta: size=", contenitore_pianta.size, " visible=", contenitore_pianta.visible, " clip_contents=", contenitore_pianta.clip_contents)
	print("  frames.get_frame_count('idle')=", sprite_animato.sprite_frames.get_frame_count("idle"))
	print("  animation playing=", sprite_animato.is_playing(), " animation=", sprite_animato.animation)


func _indice_sheet_per_texture(t: Texture2D) -> int:
	# Trova l'indice del livello che ha questa texture, per leggere
	# i frame_per_sheet corretti
	for i in dati.spritesheets.size():
		if dati.spritesheets[i] == t:
			return i
	return 0


func _carica_frames(texture: Texture2D, lv: int) -> void:
	var frames: SpriteFrames = SpriteFrames.new()
	# Rimuovi animazione "default" che SpriteFrames crea automaticamente
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", dati.fps_animazione)

	var tot_frames: int = dati.frame_per_livello(lv)
	print("    _carica_frames: lv=", lv, " tot_frames=", tot_frames, " texture_size=", texture.get_size())

	for i in tot_frames:
		var col: int = i % SHEET_COLS
		var row: int = i / SHEET_COLS
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(
			col * SHEET_FRAME_W,
			row * SHEET_FRAME_H,
			SHEET_FRAME_W,
			SHEET_FRAME_H
		)
		frames.add_frame("idle", atlas)

	print("    dopo loop: frame_count=", frames.get_frame_count("idle"))
	sprite_animato.sprite_frames = frames
	print("    sprite_animato.sprite_frames assegnato: ", sprite_animato.sprite_frames)


func _rimuovi_sprite() -> void:
	if sprite_animato != null:
		sprite_animato.queue_free()
		sprite_animato = null


func _mostra_placeholder(visibile: bool) -> void:
	foglia_base.visible = visibile
	foglia_secondaria.visible = visibile
	decorazione.visible = false


# ============================================================
# AZIONI
# ============================================================

func _su_annaffia_premuto() -> void:
	if matura:
		return
	aggiungi_acqua(dati.acqua_per_tap, true)
	ProgressoGiocatore.registra_annaffiatura()


func _su_raccogli_premuto() -> void:
	if not matura:
		return
	var livello_prima: int = _livello_visivo_attuale()
	_mostra_label_semi(dati.semi_per_raccolto)
	matura = false
	acqua_attuale = 0.0
	raccolte_cumulative += 1
	var livello_dopo: int = _livello_visivo_attuale()
	if livello_dopo != livello_prima:
		_aggiorna_sprite()
		_anima_level_up_pianta()
	else:
		_aggiorna_badge()
	aggiorna_visuale()
	raccolta_effettuata.emit(dati.semi_per_raccolto)
	stato_cambiato.emit()


func aggiungi_acqua(quantita: float, emetti_segnale: bool) -> void:
	if matura:
		return
	var era_immatura: bool = not matura
	acqua_attuale += quantita
	if acqua_attuale >= dati.acqua_per_crescita:
		acqua_attuale = dati.acqua_per_crescita
		matura = true
		if era_immatura:
			_anima_maturazione()
	aggiorna_visuale()
	if emetti_segnale:
		stato_cambiato.emit()


# ============================================================
# VISUALE
# ============================================================

func aggiorna_visuale() -> void:
	if dati == null:
		return
	barra.value = acqua_attuale
	pulsante_annaffia.disabled = matura
	pulsante_raccogli.disabled = not matura

	if sprite_animato != null:
		# Con sprite: niente da fare, l'animazione gira sempre
		return

	# Fallback placeholder ColorRect (vecchio sistema)
	var progresso: float = acqua_attuale / dati.acqua_per_crescita
	if matura:
		_imposta_stadio_maturo()
	elif progresso >= 0.66:
		_imposta_stadio(2, progresso)
	elif progresso >= 0.33:
		_imposta_stadio(1, progresso)
	else:
		_imposta_stadio(0, progresso)


func _imposta_stadio(stadio: int, progresso: float) -> void:
	var colore: Color = dati.colore_base.lerp(dati.colore_maturo, progresso * 0.6)
	match stadio:
		0:
			foglia_base.visible = true
			foglia_base.color = colore
			foglia_base.size = Vector2(32, 32)
			foglia_base.position = Vector2(94, 58)
			foglia_secondaria.visible = false
		1:
			foglia_base.visible = true
			foglia_base.color = colore
			foglia_base.size = Vector2(55, 60)
			foglia_base.position = Vector2(82, 38)
			foglia_secondaria.visible = true
			foglia_secondaria.color = colore.darkened(0.15)
			foglia_secondaria.size = Vector2(38, 44)
			foglia_secondaria.position = Vector2(58, 54)
		2:
			foglia_base.visible = true
			foglia_base.color = colore
			foglia_base.size = Vector2(72, 76)
			foglia_base.position = Vector2(74, 18)
			foglia_secondaria.visible = true
			foglia_secondaria.color = colore.darkened(0.15)
			foglia_secondaria.size = Vector2(50, 56)
			foglia_secondaria.position = Vector2(48, 38)


func _imposta_stadio_maturo() -> void:
	foglia_base.visible = true
	foglia_base.color = dati.colore_maturo
	foglia_base.size = Vector2(78, 82)
	foglia_base.position = Vector2(71, 14)
	foglia_secondaria.visible = true
	foglia_secondaria.color = dati.colore_maturo.darkened(0.2)
	foglia_secondaria.size = Vector2(54, 60)
	foglia_secondaria.position = Vector2(44, 34)


# ============================================================
# ANIMAZIONI
# ============================================================

func _anima_maturazione() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(contenitore_pianta, "scale", Vector2(1.25, 1.25), 0.18)
	tween.tween_property(contenitore_pianta, "scale", Vector2(1.0, 1.0), 0.22)


func _anima_level_up_pianta() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(contenitore_pianta, "scale", Vector2(1.35, 1.35), 0.20)
	tween.tween_property(contenitore_pianta, "scale", Vector2(1.0, 1.0), 0.30)
	# Pop anche sul badge
	if badge_livello != null:
		var t2: Tween = create_tween()
		t2.set_ease(Tween.EASE_OUT)
		t2.set_trans(Tween.TRANS_BACK)
		t2.tween_property(badge_livello, "scale", Vector2(1.5, 1.5), 0.18)
		t2.tween_property(badge_livello, "scale", Vector2(1.0, 1.0), 0.22)
	_mostra_label_level_up()


func _mostra_label_level_up() -> void:
	var lv: int = _livello_visivo_attuale() + 1
	var label: Label = Label.new()
	label.text = "Lv. %d! ✨" % lv
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.90, 0.70, 0.10, 1.0))
	label.position = Vector2(50, 50)
	add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", Vector2(50, -20), 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.chain().tween_callback(label.queue_free)


func _mostra_label_semi(quantita: int) -> void:
	var label: Label = Label.new()
	label.text = "+%d 🌱" % quantita
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.29, 0.55, 0.16, 1.0))
	label.position = Vector2(70, 60)
	add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", Vector2(70, -10), 0.9)
	tween.tween_property(label, "modulate:a", 0.0, 0.9)
	tween.chain().tween_callback(label.queue_free)
