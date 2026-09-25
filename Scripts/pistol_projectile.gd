extends CharacterBody2D

func _physics_process(delta: float) -> void:
	# Move the bullet forward every frame based on its velocity
	position += velocity * delta
	move_and_slide()
