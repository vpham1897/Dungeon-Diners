## Code for player

extends CharacterBody2D

## Gets inventory_manager to actually execute using the item.
signal use_item(source : Node2D)

#region basic movement variables
## max speed without modifiers
var BaseMaxSPEED = 800
## acceleration without modifiers
var BaseAcceleration = 500
## deceleration without modifiers
var BaseDeceleration = 500
## actual current acceleration
var acceleration = BaseAcceleration
## actual current deceleration
var deceleration = BaseDeceleration
## actual max speed
var maxSPEED = BaseMaxSPEED
#endregion

#region dashing variables
## how strong the dash is
@export var dash_strength = 2
## how long until can dash again
var dash_cooldown_timer = 0
## the dash actual cooldown
var max_dash_cooldown = 1
## how long the dash lasts for
var dash_duration: float = 0.5
## how long the dash actually accelerates
var dash_accelerate_duration: float = .25
## time left in current dash
var dash_timer: float = 0.0
## bool to keep track of if the character is currently dashing
var is_dashing: bool = false
## a vector representing the direction relative to the character it's dashing towards
var dashdirection
#endregion

#region item variables
## how long until can use item again
var item_cooldown_timer = 0
## the item actual cooldown
var max_item_cooldown = 1
#endregion

#region tileset variables
## the tilemap to represent data on certain spots such as slowing terrain.
@export var data_tile_map: TileMapLayer
## the tilemap for physics collisions
@export var collision_map: TileMapLayer
## variable to store the tile the character's currently on
var tile_data
## variable to keep track of the state of the tile the character is currently on
var currentTileCondition
#endregion

## Most of the physics occurs here
func _physics_process(delta):
	acceleration = BaseAcceleration
	deceleration = BaseDeceleration
	maxSPEED = BaseMaxSPEED
	
	terrainModdedSpeeds()
	cap_speed(maxSPEED)

	#region dashing
	#start dashing	
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer == 0:
		dash_cooldown_timer = max_dash_cooldown
		dashdirection = (get_global_mouse_position()-global_position).normalized()
		print(dashdirection)
		dash_timer = dash_duration
		is_dashing = true
		print("dashing")
	
	# If dashing, reduce timer but still allow normal input smoothing
	if is_dashing:
		if dash_timer > dash_duration - dash_accelerate_duration:
			velocity = velocity.move_toward(dashdirection * maxSPEED, acceleration * dash_strength * delta)
		dash_timer -= delta
		#print("accelerating from dashing")
		if dash_timer <= 0:
			is_dashing = false
			print("done accelerating")
	#endregion
	
	## input direction 
	var direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")

	# Accelerate with input. Decelerate when not dashing or when over max speed.	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * maxSPEED, acceleration * delta)
	elif not is_dashing || velocity.length() > maxSPEED:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move(delta)

	# This is where my animation would be if I had any
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	# Look only if not mid dashing/item usage. Lower cooldown otherwise 
	if item_cooldown_timer <= 0 && dash_cooldown_timer <= 0:
		look_at(get_global_mouse_position())
	else:
		item_cooldown_timer = max(item_cooldown_timer - delta, 0)
		dash_cooldown_timer = max(dash_cooldown_timer - delta, 0)

## This modifies speed in accordance to the terrain underneath
func terrainModdedSpeeds():
	if data_tile_map!= null: #does FloorData exist
		tile_data = data_tile_map.get_tile_info_at(global_position)
		if tile_data != null: #if there is data at that tile
			#get the string thats in the tileCondition so Sticky ect
			currentTileCondition = tile_data.get_custom_data("TileCondition") 
			#print("TileCondition: ", currentTileCondition)
		else:
			#print("No tile under player, setting to Crisp")
			currentTileCondition = "Crisp"
	else:
		push_error("TileMap reference is missing!")

	#Balance speed values
	var High = 2
	var Low = 0.5
	match currentTileCondition:
		"Crisp":
			acceleration *= High
			deceleration *= High
		"Slippery":
			acceleration *= Low
			deceleration *= Low
			maxSPEED *= High
		"Sticky" :
			acceleration *= Low
			deceleration *= High
			maxSPEED *= Low

## Resolves move as collisisions need to be handled specially
func move(delta):
	# check if about to collide.
	var collision = move_and_collide(velocity * delta, true)
	if collision:
		var target = collision.get_position() - collision.get_normal() * 4
		#print(collision.get_collider())
		var tile = collision_map.get_tile_info_at(target)
		if tile:
			## int value that maps to which directions character can vault in relation to this tile. See FloorData
			var vaultable = String.num_int64(tile.get_custom_data("Direction"), 2).lpad(4, "0")
			print("vaultable: ")
			print(vaultable[0] + vaultable[1] + vaultable [2] + vaultable [3])
			#region read the vaultable directions and check against current velocity to resolve collision.
			if is_dashing and vaultable: 
				var verticalDirection = (velocity.y < 0)
				var horizontalDirection = (velocity.x > 0)
				#print("horizontal")
				#print(horizontalDirection)
				var vaulting = false
				if (vaultable[0] == "1" and verticalDirection):
					vaulting = true
					print("vaulting up")
				else:
					if (vaultable[1] == "1" and not verticalDirection):
						vaulting = true
						print("vaulting down")
					else:
						if (vaultable[2] == "1" and not horizontalDirection):
							vaulting = true
							print("vaulting left")
						else:
							if (vaultable[3] == "1" and horizontalDirection):
								vaulting = true
								print("vaulting right")	
				# ignore collision if vaulting
				if vaulting:	
					position += velocity * delta
					return
			#endregion
		# bounce otherwise with collision
		velocity = velocity.bounce(collision.get_normal())
	# normal movement
	move_and_collide(velocity*delta)
	return

## Call this function to cap the player's speed to the given speed
func cap_speed(capped_speed) -> void:
	if velocity.length() > capped_speed:
		velocity = capped_speed * velocity.normalized()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		#region Using item code
		if item_cooldown_timer <= 0:
			# Call inventory manager's instantiate and give my stuffs
			print("using item!")
			InventoryManager.use_item(self)
			item_cooldown_timer = max_item_cooldown
		else:
			print("item on cooldown! ", item_cooldown_timer)
		#endregion

		
