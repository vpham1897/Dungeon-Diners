extends Area2D
class_name Hurtbox

@export var healthPath: NodePath
var health: Health

func _ready() -> void:
	if healthPath != NodePath():
		health = get_node_or_null(healthPath) as Health
	if health == null:
		health = get_parent().get_node_or_null("Health") as Health

func receiveHit(damageAmount: float) -> void:
	if health == null:
		print("Hurtbox has no Health node")
		return
	print("HURTBOX HIT:", get_parent().name, " dmg=", damageAmount)
	health.applyDamage(damageAmount)
	print("HP NOW:", health.currentHealth)
