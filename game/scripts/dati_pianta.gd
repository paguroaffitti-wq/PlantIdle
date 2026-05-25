extends Resource
class_name DatiPianta

# ============================================================
# RISORSA: DATI DI UN TIPO DI PIANTA
# ============================================================
# Ogni file .tres in res://data/piante/ è un'istanza di questa
# classe. Definisce le caratteristiche di un tipo (pothos,
# monstera, ecc.) editabili nell'inspector di Godot.
#
# Per creare una nuova pianta:
# 1. Click destro in FileSystem -> New Resource -> DatiPianta
# 2. Salva come "nome_pianta.tres" in res://data/piante/
# 3. Compila i campi nell'inspector
# 4. Aggiungila al preload in main.gd
# ============================================================

# --- IDENTITÀ ---
# id_pianta: stringa univoca usata nel salvataggio per ritrovare
# il .tres corretto al caricamento. NON cambiarla dopo che la
# pianta è in produzione (rompe i salvataggi degli utenti).
@export var id_pianta: String = ""
@export var nome_visualizzato: String = ""
@export_multiline var descrizione: String = ""

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
# Path agli asset reali, vuoti finché non li avremo.
@export_group("Asset finali")
@export var sprite_seme: Texture2D
@export var sprite_giovane: Texture2D
@export var sprite_maturo: Texture2D
