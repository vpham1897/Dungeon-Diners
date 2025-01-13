extends CharacterBody2D
var maxSPEED = 800
var Acceleration = 300
var Deceleration = 600
var target = Vector2.ZERO
func _physics_process(delta):
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
