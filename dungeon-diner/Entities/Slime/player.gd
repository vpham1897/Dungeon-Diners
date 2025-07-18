extends CharacterBody2D

signal use_item(source : Node2D)

var BaseMaxSPEED = 800
var BaseAcceleration = 500
var BaseDeceleration = 500
var cooldown = 0
# what attack cooldown resets.
var maxCooldown = 1

@export var dash_strength = 2
var dash_cooldown = 0
var max_dash_cooldown = 10
var dash_duration: float = .25
var dash_timer: float = 0.0
var is_dashing: bool = false
var dashdirection

var target = Vector2.ZERO
var item_cooldown = 0
var max_item_cooldown = 1

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
			#print("TileCondition: ", currentTitleData)
		else:
			#print("No tile under player, setting to Crisp")
			currentTitleData = "Crisp"
	else:
		push_error("TileMap reference is missing!")

	var acceleration = BaseAcceleration
	var deceleration = BaseDeceleration
	var maxSPEED = BaseMaxSPEED

#Balance speed values
	var High = 2
	var Low = 0.5
	if currentTitleData == "Crisp":
		acceleration *= High
		deceleration *= High
	if currentTitleData == "Slippery":
		acceleration *= Low
		deceleration *= Low
		maxSPEED *= High
	if currentTitleData == "Sticky" :
		acceleration *= Low
		deceleration *= High
		maxSPEED *= Low

	# Make transitions 
	cap_speed(maxSPEED)

	var direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	
	
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown == 0:
		dashdirection = (get_global_mouse_position()-global_position).normalized()
		print(dashdirection)
		dash_timer = dash_duration
		is_dashing = true
		print("dashing")
	
	# If dashing, reduce timer but still allow normal input smoothing
	if is_dashing:
		dash_timer -= delta
		velocity = velocity.move_toward(dashdirection * maxSPEED, acceleration * dash_strength * delta)
		print("slowing down dashing")
		if dash_timer <= 0:
			is_dashing = false
			print("done dashing")
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * maxSPEED, acceleration * delta)
	elif not is_dashing || velocity.length() > maxSPEED:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()

	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
#endregion

	if item_cooldown <= 0 && dash_cooldown <= 0:
		look_at(get_global_mouse_position())
	else:
		item_cooldown = max(item_cooldown - delta, 0)
		dash_cooldown = max(dash_cooldown - delta, 0)

# Call this function to cap the speed to the given speed
func cap_speed(capped_speed) -> void:
	if velocity.length() > capped_speed:
		velocity = capped_speed * velocity.normalized()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if item_cooldown <= 0:
			print("using item!")
			InventoryManager.use_item(self)
			item_cooldown = max_item_cooldown
		else:
			print("item on cooldown! ", item_cooldown)
		# Call inventory manager's instantiate and give my stuffs

		
