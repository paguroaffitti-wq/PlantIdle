extends Resource
class_name DatiPianta

# ============================================================
# RISORSA: DATI DI UN TIPO DI PIANTA
# ============================================================
# Ogni file .tres in res://data/piante/ è un'istanza di questa
# classe. Definisce le caratteristiche di un tipo (pothos,
# monstera, ecc.) editabili nell'inspector di Godot.
# ============================================================

# --- IDENTITÀ ---
@export var id_pianta: String = ""
@export var nome_visualizzato: String = ""
@export_multiline var descrizione: String = ""

# --- ECONOMY (M1 Step 3) ---
# Costo in semi per sbloccare questo tipo nello shop.
# Se 0 = pianta gratuita/iniziale (es. Pothos).
@export_group("Economy")
@export var costo_sblocco: int = 0

# --- BILANCIAMENTO ---
@export_group("Bilanciamento")
@export var acqua_per_crescita: float = 100.0
@export var acqua_per_tap: float = 5.0
@export var acqua_passiva_al_secondo: float = 1.0
@export var semi_per_raccolto: int = 10

# --- ESTETICA PLACEHOLDER (M1-M2) ---
@export_group("Estetica placeholder")
@export var colore_base: Color = Color(0.4, 0.6, 0.3)
@export var colore_maturo: Color = Color(0.2, 0.7, 0.2)

# --- ESTETICA FINALE (M3) ---
@export_group("Asset finali")
@export var sprite_seme: Texture2D
@export var sprite_giovane: Texture2D
@export var sprite_maturo: Texture2D
