extends CharacterBody2D

var current_bounces: int


func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()
		
	# Move the bullet forward every frame based on its velocity
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is StaticBody2D or collider is TileMapLayer:
			if current_bounces > 0:
			# Bounce away from the wall using the collision normal
				var normal = collision.get_normal()
			
				# Reflect velocity and remainder
				velocity = velocity.bounce(normal)
				var remainder = collision.get_remainder().bounce(normal)
				move_and_collide(remainder)
				current_bounces -= 1
			else:
				queue_free() # Out of bounces, destroy!
