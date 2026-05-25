extends Control
class_name Pianta

# ============================================================
# MILESTONE 1 STEP 4 - Pianta con estetica cottagecore
# ============================================================
# Novità rispetto a Step 3:
# - 3 stadi visivi distinti (germoglio / giovane / maturo)
# - Animazione "pop" quando la pianta matura (Tween scala)
# - Label "+N 🌱" che fluttua su e sparisce alla raccolta
# - Vaso di terracotta come elemento separato (gestito nella scena)
# ============================================================

signal raccolta_effettuata(quantita_semi: int)
signal stato_cambiato

var dati: DatiPianta
var indice_slot: int = -1
var acqua_attuale: float = 0.0
var matura: bool = false

# Riferimenti nodi
@onready var foglia_base: ColorRect = $Pianta/FogliaBase
@onready var foglia_secondaria: ColorRect = $Pianta/FogliaSecondaria
@onready var decorazione: ColorRect = $Pianta/Decorazione
@onready var barra: ProgressBar = $Barra
@onready var pulsante_annaffia: Button = $PulsanteAnnaffia
@onready var pulsante_raccogli: Button = $PulsanteRaccogli
@onready var label_nome: Label = $LabelNome


func imposta(d: DatiPianta, slot: int, stato: Dictionary) -> void:
	dati = d
	indice_slot = slot
	acqua_attuale = stato.get("acqua_attuale", 0.0)
	matura = stato.get("matura", false)
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
	aggiorna_visuale()


func ottieni_stato() -> Dictionary:
	return {
		"id_pianta": dati.id_pianta,
		"acqua_attuale": acqua_attuale,
		"matura": matura,
	}


func applica_crescita_passiva(secondi: float) -> void:
	if matura or dati == null:
		return
	aggiungi_acqua(secondi * dati.acqua_passiva_al_secondo, false)


# ============================================================
# AZIONI
# ============================================================

func _su_annaffia_premuto() -> void:
	if matura:
		return
	aggiungi_acqua(dati.acqua_per_tap, true)


func _su_raccogli_premuto() -> void:
	if not matura:
		return
	_mostra_label_semi(dati.semi_per_raccolto)
	matura = false
	acqua_attuale = 0.0
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
# VISUALE — 3 stadi
# ============================================================
# Stadio 0 — Germoglio  (0%–33%):  solo foglia_base piccola
# Stadio 1 — Giovane    (33%–66%): foglia_base + foglia_secondaria
# Stadio 2 — Maturo     (66%–100%): tutto + decorazione (fiorellino)
# ============================================================

func aggiorna_visuale() -> void:
	if dati == null:
		return

	barra.value = acqua_attuale
	pulsante_annaffia.disabled = matura
	pulsante_raccogli.disabled = not matura

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
		0:  # Germoglio
			foglia_base.visible = true
			foglia_base.color = colore
			foglia_base.size = Vector2(30, 30)
			foglia_base.position = Vector2(55, 60)
			foglia_secondaria.visible = false
			decorazione.visible = false

		1:  # Giovane
			foglia_base.visible = true
			foglia_base.color = colore
			foglia_base.size = Vector2(50, 55)
			foglia_base.position = Vector2(45, 40)
			foglia_secondaria.visible = true
			foglia_secondaria.color = colore.darkened(0.15)
			foglia_secondaria.size = Vector2(35, 40)
			foglia_secondaria.position = Vector2(25, 55)
			decorazione.visible = false

		2:  # Quasi maturo
			foglia_base.visible = true
			foglia_base.color = colore
			foglia_base.size = Vector2(65, 70)
			foglia_base.position = Vector2(37, 20)
			foglia_secondaria.visible = true
			foglia_secondaria.color = colore.darkened(0.15)
			foglia_secondaria.size = Vector2(45, 50)
			foglia_secondaria.position = Vector2(18, 40)
			decorazione.visible = false


func _imposta_stadio_maturo() -> void:
	foglia_base.visible = true
	foglia_base.color = dati.colore_maturo
	foglia_base.size = Vector2(70, 75)
	foglia_base.position = Vector2(35, 15)

	foglia_secondaria.visible = true
	foglia_secondaria.color = dati.colore_maturo.darkened(0.2)
	foglia_secondaria.size = Vector2(50, 55)
	foglia_secondaria.position = Vector2(15, 35)

	decorazione.visible = true
	decorazione.color = Color(0.95, 0.85, 0.50, 1)  # giallo caldo: fiorellino
	decorazione.size = Vector2(18, 18)
	decorazione.position = Vector2(75, 10)


# ============================================================
# ANIMAZIONI
# ============================================================

func _anima_maturazione() -> void:
	# Pop di scala: la foglia_base cresce a 1.25x poi torna a 1.0
	var contenitore_pianta: Control = $Pianta
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(contenitore_pianta, "scale", Vector2(1.25, 1.25), 0.18)
	tween.tween_property(contenitore_pianta, "scale", Vector2(1.0, 1.0), 0.22)


func _mostra_label_semi(quantita: int) -> void:
	# Crea una Label temporanea che sale e sparisce
	var label: Label = Label.new()
	label.text = "+%d 🌱" % quantita
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.29, 0.55, 0.16, 1.0))
	label.position = Vector2(30, 60)
	add_child(label)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", Vector2(30, -10), 0.9)
	tween.tween_property(label, "modulate:a", 0.0, 0.9)
	tween.chain().tween_callback(label.queue_free)
