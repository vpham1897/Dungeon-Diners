extends CharacterBody2D

signal use_item(source : Node2D)

var maxSPEED = 800
var Acceleration = 300
var Deceleration = 600
var target = Vector2.ZERO
var cooldown = 0
# what attack cooldown resets.
var maxCooldown = 1

func _ready():
	pass

func _physics_process(delta):
	if cooldown > 0:
		cooldown -= delta
	var direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * maxSPEED, Acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Deceleration * delta)
	move_and_slide()
	
	if cooldown <= 0:
		look_at(get_global_mouse_position())
	
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if cooldown <= 0:
			print("using item!")
			InventoryManager.use_item(self)
			cooldown = maxCooldown
		else:
			print("on cooldown! ", cooldown)
		# Call inventory manager's instantiate and give my stuffs
