extends CharacterBody2D

@onready var health: Health = $Health

func _ready() -> void:
	health.died.connect(_onDied)

func _onDied() -> void:
	queue_free()
