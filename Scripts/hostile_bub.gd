class_name HostileBub
extends Enemy

@export var projectile_scene: PackedScene
@onready var attackTimer: Timer = $AttackTimer
var projectile_speed: int = 60

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# 1. Measure the exact pixel distance to the player
		var distance = global_position.distance_to(player.global_position)
		
		# 2. Check if they are inside the aggro range from your resource data
		if distance <= spawned_enemy.aggro_range:
			if can_shoot:
				shoot(player)
		else:
			# Player is too far away
			pass
	

func shoot(target_node: Node2D) -> void:
	if can_shoot() == false:
		return
	attackTimer.start()
	print("I am shooting the player!")
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		var direction = global_position.direction_to(target_node.global_position)
		projectile.velocity = direction * projectile_speed

		get_tree().current_scene.add_child(projectile)
	else:
		print("No projectile to shoot!")
	
func can_shoot() -> bool:
	return attackTimer.is_stopped()
