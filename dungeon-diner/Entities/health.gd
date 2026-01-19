extends Node
class_name Health
@export var maxHealth: float = 100.0
var currentHealth: float

signal died
func _ready() -> void:
	currentHealth = maxHealth

func applyDamage(amount: float) -> void:
	currentHealth = max(currentHealth - amount, 0.0)

	if currentHealth <= 0.0:
		die()

func die() -> void:
	emit_signal("died")
