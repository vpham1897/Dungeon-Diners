extends Area2D
class_name Hitbox

@export var damage: float = 10.0

var ownerNode: Node2D
var alreadyHit: Dictionary = {}
func _physics_process(_delta: float) -> void:
	monitoring = true

func configureForOwner(isPlayerOwner: bool, owner: Node2D) -> void:
	ownerNode = owner
	alreadyHit.clear()
	monitoring = true
	debugPrintOverlapsFor(.8)


	collision_mask = 0
	if isPlayerOwner:
		set_collision_mask_value(2, true) # Enemy layer
	else:
		set_collision_mask_value(1, true) # Player layer

func _ready() -> void:
	#print("HITBOX _ready fired")
	monitoring = true
	monitorable = true
	area_entered.connect(_onAreaEntered)

func _onAreaEntered(area: Area2D) -> void:
	print("AREA ENTERED:", area.name, " parent=", area.get_parent().name)
	# Ignore anything on the owner (prevents hitting yourself)
	if ownerNode != null and ownerNode.is_ancestor_of(area):
		print("if ownerNode != null and ownerNode.is_ancestor_of(area):")
		return

	# Only hurt hurtboxes
	if not (area is Hurtbox):
		print("if not (area is Hurtbox):")
		return

	# One hit per target per swing
	if alreadyHit.has(area):
		print("if alreadyHit.has(area):")
		return
	alreadyHit[area] = true
	print("DAMAGE APPLIED TO:", area.get_parent().name)
	(area as Hurtbox).receiveHit(damage)
	
func debugPrintOverlapsFor(duration: float) -> void:
	var t: float = 0.0
	while t < duration:
		await get_tree().physics_frame
		var overlaps = get_overlapping_areas()
		if overlaps.size() > 0:
			var names: Array[String] = []
			for a in overlaps:
				names.append(a.get_parent().name)
			print("OVERLAPS WITH:", names)
		t += get_physics_process_delta_time()
