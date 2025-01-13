extends Node2D

# a selected index of -1 should be "nothing" is selected
var selectedIndex : int
var inventory : Array[Resource]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#follow the below format to add things to the inventory	
	# This is for testing purposes. Ideally, this will be added 
	add_inventory(preload("res://Items/TestStick/TestStick.tscn"))
	add_inventory(null)
	selectedIndex = 0
	pass # Replace with function body.

#Load the node file and add to the inventory.
func add_inventory(node : Resource):
	inventory.append(node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func use_item(source: Node2D) -> void:
	# a selected index of -1 should be "nothing" is selected
	if selectedIndex == -1:
		return
	
	# check if index is not valid
	if (selectedIndex > inventory.size() or (selectedIndex < 0) or (not inventory[selectedIndex])):
		print("invalid slot!!!")
		return
	
	print("using item")
	var itemInstance = inventory[selectedIndex].instantiate()
	source.add_child(itemInstance)
	itemInstance.attack()
	pass # Replace with function body.
