extends CharacterBody2D

signal use_item(source : Node2D)

var maxSPEED = 800
var BaseAcceleration = 300
var BaseDeceleration = 600
var target = Vector2.ZERO
var cooldown = 0
# what attack cooldown resets.
var maxCooldown = 1

#tileset variables
@export var data_tile_map: TileMapLayer

var currentTitleData
var tile_data

func _physics_process(delta):

#region movement
#get tile data
	if data_tile_map!= null: #does FloorData exist
		tile_data = data_tile_map.get_tile_info_at(global_position)
		if tile_data != null: #if there is a data at that tile
			#get the string thats in the tileCondition so Sticky ect
			currentTitleData = tile_data.get_custom_data("TileCondition") 
			print("TileCondition: ", currentTitleData)
		else:
			print("No tile under player, setting to Crisp")
			currentTitleData = "Crisp"
	else:
		push_error("TileMap reference is missing!")

	var Acceleration = BaseAcceleration
	var Deceleration = BaseDeceleration

#Balance speed values
	var High = 2
	var Low = 0.5
	if currentTitleData == "Crisp":
		Acceleration *= High
		Deceleration *= High
	if currentTitleData == "Slippery":
		Acceleration *= Low
		Deceleration *= Low
	if currentTitleData == "Sticky" :
		Acceleration *= Low
		Deceleration *= High


#Input movement commands
	var direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * maxSPEED, Acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Deceleration * delta)
	move_and_slide()
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
#endregion

	if cooldown <= 0:
		look_at(get_global_mouse_position())
	else:
		cooldown -= delta
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if cooldown <= 0:
			print("using item!")
			InventoryManager.use_item(self)
			cooldown = maxCooldown
		else:
			print("on cooldown! ", cooldown)
		# Call inventory manager's instantiate and give my stuffs
		
