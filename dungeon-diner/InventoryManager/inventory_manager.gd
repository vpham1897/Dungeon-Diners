extends Node2D

@onready var testStick = preload("res://Items/TestStick/TestStick.tscn")
@export var item : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func use_item(source: Node2D) -> void:
	print("using item")
	var itemInstance = testStick.instantiate()
	source.add_child(itemInstance)
	pass # Replace with function body.
