extends Node2D

class_name BaseItem

var hurtbox
var sprite
var damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = $AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Implement in extended classes
func attack():
	pass
		
func interact():
	pass


func finished_animation(anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.
