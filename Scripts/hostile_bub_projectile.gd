extends CharacterBody2D

var on_hit_damage: int = 1
var speed: int

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			collider.take_damage(on_hit_damage)
			queue_free()
