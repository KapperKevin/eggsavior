extends CharacterBody2D

@export var stats: PlayerStats
@export var weapon_scene: PackedScene

@onready var reticle_node: Sprite2D = $Reticle
@onready var gun_pivot: Node2D = $GunPivot

var weapon_spawn_node: Node2D
var orbit_distance: float = 15.0
var speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Setting the Player's Stats
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
	#Temporay healing function
	if event.is_action_pressed("ui_text_completion_accept") or Input.is_key_pressed(KEY_H):
		stats.heal(2)
		get_tree().get_first_node_in_group("hud").update_hud()
		print("Healed! Current HP: ", stats.current_player_health)
	
func fire_weapon() -> void:
	weapon_spawn_node.shooting()
	
func death() -> void:
	print("You Died!")
	queue_free()
	
func take_damage(damage_recieved: int) -> void:
	print(damage_recieved)
	if stats.egg_extra_hitpoints > 0:
		stats.egg_extra_hitpoints -= 1
		print("You lost an Egg!")
	else:
		stats.current_player_health -= damage_recieved
		get_tree().get_first_node_in_group("hud").update_hud()
	if stats.current_player_health <= 0:
		print(stats.current_player_health)
		death()

#Temporary
	
