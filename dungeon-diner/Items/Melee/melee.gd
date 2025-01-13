extends BaseItem

class_name Melee

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	attack()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func attack():
	print("attack!")
	sprite.play()
	pass

func finished_animation():
	print("bye bye")
	super()
	pass
