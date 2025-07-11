extends BaseItem

class_name Melee

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	attack()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since th previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func attack():
	print("attack!")
	sprite.play("Swing")
	pass

func finished_animation(anim_name: StringName):
	print("bye bye")
	super(anim_name)
	pass
