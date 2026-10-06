class_name Snake
extends Enemy


func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		var direction = get_path_direction(player.global_position)
		velocity = direction * current_speed
		move_and_slide()
