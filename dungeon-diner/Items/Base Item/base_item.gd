extends Node2D

class_name BaseItem

var hurtbox
var sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurtbox = $Hurtbox
	sprite = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func attack():
	pass
		
func interact():
	pass
