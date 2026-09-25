extends CharacterBody2D

@export var stats: PlayerStats
@export var weapon_scene: PackedScene

@onready var reticle_node: Sprite2D = $Reticle
@onready var gun_pivot: Node2D = $GunPivot

var weapon_spawn_node: Node2D
var orbit_distance: float = 20.0
var speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = stats.current_player_speed
	#Equiping Guns
	if weapon_scene:
		weapon_spawn_node = weapon_scene.instantiate()
		gun_pivot.add_child(weapon_spawn_node)
		weapon_spawn_node.position = Vector2(orbit_distance, 0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#MOVING
	movementLoop()
	
	#GUN ORBIT & DIRECTION
	var mouse_pos = get_global_mouse_position()
	
	if gun_pivot:
		gun_pivot.look_at(mouse_pos)
		if mouse_pos.x < global_position.x:				
			weapon_spawn_node.scale.y = -1
		else:
			weapon_spawn_node.scale.y = 1
			
	reticle_node.position = mouse_pos - global_position

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

func collect_egg(egg: EggData) -> void:
	stats.apply_effect(egg)
	speed = stats.current_player_speed
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		fire_weapon()
	
func fire_weapon() -> void:
	weapon_spawn_node.shooting()
