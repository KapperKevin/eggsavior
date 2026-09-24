extends Area2D


@export var speed: float = 300.0
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Move the bullet forward every frame based on its velocity
	position += velocity * delta
