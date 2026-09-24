extends CharacterBody2D

@export var stats: PlayerStats
@export var weapon_scene: PackedScene

var weapon_spawn_node: Node2D
var speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = stats.current_player_speed
	#Equiping Gun
	if weapon_scene:
		weapon_spawn_node = weapon_scene.instantiate()
		add_child(weapon_spawn_node)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movementLoop()

func movementLoop() -> void:
	# Get the input direction from the WASD actions
	var direction := Input.get_vector("left", "right", "up", "down")
	
	# Set velocity based on direction and speed
	if direction:
		#aba
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	# Move the character
	move_and_slide()

func collect_egg(egg: Egg) -> void:
	stats.apply_effect(egg)
	speed = stats.current_player_speed
	
func shoot() -> void:
	pass
	
