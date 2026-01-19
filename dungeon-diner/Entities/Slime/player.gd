extends CharacterBody2D

var BaseMaxSPEED = 800
var BaseAcceleration = 500
var BaseDeceleration = 500

@export var dash_strength = 2
var dash_cooldown = 0.0
var max_dash_cooldown = 10.0
var dash_duration: float = 0.25
var dash_timer: float = 0.0
var is_dashing: bool = false
var dashdirection: Vector2 = Vector2.ZERO

@export var meleeScene: PackedScene

var item_cooldown: float = 0.0
var max_item_cooldown: float = 1.0

#tileset variables
@export var data_tile_map: TileMapLayer
var currentTitleData: String = "Crisp"
var tile_data

@export var enemyScene: PackedScene

func _physics_process(delta: float) -> void:
	#region movement
	#get tile data
	if data_tile_map != null:
		tile_data = data_tile_map.get_tile_info_at(global_position)
		if tile_data != null:
			currentTitleData = str(tile_data.get_custom_data("TileCondition"))
		else:
			currentTitleData = "Crisp"
	else:
		push_error("TileMap reference is missing!")

	var acceleration = BaseAcceleration
	var deceleration = BaseDeceleration
	var maxSPEED = BaseMaxSPEED

	#Balance speed values
	var High = 2.0
	var Low = 0.5
	if currentTitleData == "Crisp":
		acceleration *= High
		deceleration *= High
	elif currentTitleData == "Slippery":
		acceleration *= Low
		deceleration *= Low
		maxSPEED *= High
	elif currentTitleData == "Sticky":
		acceleration *= Low
		deceleration *= High
		maxSPEED *= Low

	cap_speed(maxSPEED)

	var direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")

	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown <= 0.0:
		dashdirection = (get_global_mouse_position() - global_position).normalized()
		dash_timer = dash_duration
		is_dashing = true
		dash_cooldown = max_dash_cooldown

	if is_dashing:
		dash_timer -= delta
		velocity = velocity.move_toward(dashdirection * maxSPEED, acceleration * dash_strength * delta)
		if dash_timer <= 0.0:
			is_dashing = false

	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * maxSPEED, acceleration * delta)
	elif not is_dashing or velocity.length() > maxSPEED:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()

	if velocity.length() > 0.0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	#endregion

	# cooldown timers
	item_cooldown = max(item_cooldown - delta, 0.0)
	dash_cooldown = max(dash_cooldown - delta, 0.0)

	# rotate to mouse only when not locked by cooldown
	if item_cooldown <= 0.0 and dash_cooldown <= 0.0:
		look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		spawnEnemyAtCursor()

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("CLICK RECEIVED BY PLAYER")
		tryAttack()

func tryAttack() -> void:
	#print("tryAttack called. cooldown=", item_cooldown)

	if item_cooldown > 0.0:
		print("BLOCKED BY COOLDOWN")
		return

	if meleeScene == null:
		print("meleeScene is NULL (not set in Inspector)")
		return

	item_cooldown = max_item_cooldown

	var meleeInstance = meleeScene.instantiate() as Node2D
	add_child(meleeInstance)

	#print("Spawned melee:", meleeInstance, " parent=", meleeInstance.get_parent())

	meleeInstance.global_position = global_position
	meleeInstance.global_rotation = (get_global_mouse_position() - global_position).angle()

	if meleeInstance.has_method("startAttack"):
		#print("Calling startAttack(true,self)")
		meleeInstance.startAttack(true, self)
	else:
		print("ERROR: spawned melee has NO startAttack() method")

func cap_speed(capped_speed: float) -> void:
	if velocity.length() > capped_speed:
		velocity = capped_speed * velocity.normalized()
		
func spawnEnemyAtCursor() -> void:
	if enemyScene == null:
		push_error("enemyScene not set on Player")
		return

	var enemyInstance = enemyScene.instantiate() as Node2D
	get_parent().add_child(enemyInstance)

	enemyInstance.global_position = get_global_mouse_position()
