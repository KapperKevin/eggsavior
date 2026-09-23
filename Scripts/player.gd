extends CharacterBody2D

@export var stats: PlayerStats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movementLoop()

func movementLoop() -> void:
	# Get the input direction from the WASD actions
	var direction := Input.get_vector("left", "right", "up", "down")
	
	# Set velocity based on direction and speed
	if direction:
		#aba
		velocity = direction * stats.base_player_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, stats.base_player_speed)
	
	# Move the character
	move_and_slide()
