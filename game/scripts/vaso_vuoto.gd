extends Control
class_name VasoVuoto

# ============================================================
# VASO VUOTO - placeholder cliccabile per slot vuoti
# ============================================================
# Stesso "ingombro" di una Pianta (140x360) così convive con le
# vere piante nello stesso HBoxContainer.
# Emette un segnale al giardino quando cliccato.
# ============================================================

signal click_pianta_qui

@onready var pulsante: Button = $Pulsante


func _ready() -> void:
	pulsante.pressed.connect(func(): click_pianta_qui.emit())
