extends Node2D
class_name Melee

@export var damage: float = 10.0
@export var activeTime: float = 0.8

@onready var hitboxArea: Area2D = $Hitbox
@onready var hitboxPoly: CollisionPolygon2D = $Hitbox/"Hitbox Shape"

var ownerNode: Node2D
var alreadyHit: Dictionary = {}
var isPlayerOwner: bool = true

func startAttack(fromPlayer: bool, owner: Node2D) -> void:
	isPlayerOwner = fromPlayer
	ownerNode = owner
	alreadyHit.clear()

	# Ensure the hitbox is on Weapon layer (3) and queries Enemy layer (2)
	hitboxArea.collision_layer = 0
	hitboxArea.set_collision_layer_value(3, true)

	hitboxArea.collision_mask = 0
	if isPlayerOwner:
		hitboxArea.set_collision_mask_value(2, true) # Enemy
	else:
		hitboxArea.set_collision_mask_value(1, true) # Player

	$AnimationPlayer.play("Swing")

	var t: float = 0.0
	while t < activeTime:
		await get_tree().physics_frame
		performHitQuery()
		t += get_physics_process_delta_time()

	queue_free()

func performHitQuery() -> void:
	# Build a convex shape from the polygon
	var polyPoints: PackedVector2Array = hitboxPoly.polygon
	if polyPoints.size() < 3:
		return

	var shape := ConvexPolygonShape2D.new()
	shape.points = polyPoints

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = hitboxPoly.global_transform
	params.collision_mask = hitboxArea.collision_mask
	params.collide_with_areas = true
	params.collide_with_bodies = false

	var spaceState = get_world_2d().direct_space_state
	var results = spaceState.intersect_shape(params, 16)

	for r in results:
		var collider = r.get("collider")
		if collider == null:
			continue

		# collider will be an Area2D if it hit a hurtbox
		if collider is Area2D:
			var area := collider as Area2D

			# Ignore owner subtree (prevents self-hits)
			if ownerNode != null and ownerNode.is_ancestor_of(area):
				continue

			# Only hit hurtboxes
			if not area.has_method("receiveHit"):
				continue

			# One hit per target per swing
			if alreadyHit.has(area):
				continue
			alreadyHit[area] = true

			area.receiveHit(damage)
