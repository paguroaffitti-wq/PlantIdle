extends Resource
class_name DatiPianta

# ============================================================
# RISORSA: DATI DI UN TIPO DI PIANTA
# ============================================================

# --- IDENTITÀ ---
@export var id_pianta: String = ""
@export var nome_visualizzato: String = ""
@export_multiline var descrizione: String = ""

# --- ECONOMY ---
@export_group("Economy")
@export var costo_sblocco: int = 0

# --- BILANCIAMENTO ---
@export_group("Bilanciamento")
@export var acqua_per_crescita: float = 100.0
@export var acqua_per_tap: float = 5.0
@export var acqua_passiva_al_secondo: float = 1.0
@export var semi_per_raccolto: int = 10

# --- LIVELLI VISIVI ---
@export_group("Livelli visivi")
@export var raccolte_per_livello: Array[int] = []
@export var spritesheets: Array[Texture2D] = []
@export var frame_per_sheet: Array[int] = []
@export var fps_animazione: int = 12

# --- ESTETICA PLACEHOLDER ---
@export_group("Estetica placeholder")
@export var colore_base: Color = Color(0.4, 0.6, 0.3)
@export var colore_maturo: Color = Color(0.2, 0.7, 0.2)


# Default robusto: 94 frame (10x10 - 6 vuoti).
# Se l'array è vuoto o il valore è 0/negativo, usa il default.
const FRAME_DEFAULT: int = 94


func livello_visivo(raccolte: int) -> int:
	var lv: int = 0
	for soglia in raccolte_per_livello:
		if raccolte >= soglia:
			lv += 1
		else:
			break
	return lv


func spritesheet_per_livello(lv: int) -> Texture2D:
	if lv < spritesheets.size():
		return spritesheets[lv]
	return null


func frame_per_livello(lv: int) -> int:
	if lv < frame_per_sheet.size():
		var val: int = frame_per_sheet[lv]
		if val > 0:
			return val
	return FRAME_DEFAULT
