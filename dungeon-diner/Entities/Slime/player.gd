extends CharacterBody2D

signal use_item(source : Node2D)

var maxSPEED = 800
var BaseAcceleration = 300
var BaseDeceleration = 600
var target = Vector2.ZERO
var cooldown = 0
# what attack cooldown resets.
var maxCooldown = 1

@export var dash_strength = 100000000000000000
var dash_cooldown = 0
var max_dash_cooldown = 10
var dash_duration: float = .5
var dash_timer: float = 0.0
var is_dashing: bool = false
var dashing_direction: Vector2 = Vector2.ZERO

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

	var direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown == 0:
		var dashdirection = (get_global_mouse_position()-global_position).normalized()
		
		velocity = dashdirection * dash_strength
		dash_timer = dash_duration
		is_dashing = true
		print("dashing")
	
	# If dashing, reduce timer but still allow normal input smoothing
	if is_dashing:
		dash_timer -= delta
		print("slowing down dashing")
		if dash_timer <= 0:
			is_dashing = false
			print("done dashing")

	# Normal smooth movement only when not dashing
	if not is_dashing:
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

	if item_cooldown <= 0:
		look_at(get_global_mouse_position())
	else:
		item_cooldown -= delta
	if dash_cooldown <= 0:
		look_at(get_global_mouse_position())
	else:
		dash_cooldown -= delta

var target = Vector2.ZERO
var item_cooldown = 0
var max_item_cooldown = 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if item_cooldown <= 0:
			print("using item!")
			InventoryManager.use_item(self)
			item_cooldown = max_item_cooldown
		else:
			print("item on cooldown! ", item_cooldown)
		# Call inventory manager's instantiate and give my stuffs

		
