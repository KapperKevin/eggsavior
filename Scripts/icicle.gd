extends CharacterBody2D

var on_hit_damage: int
var direction: Vector2

func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()
		
	# Move the bullet forward every frame based on its velocity
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("enemy"):
			collider.take_damage(on_hit_damage)
			queue_free()
			
		if collider is StaticBody2D or collider is TileMapLayer:
			queue_free()
