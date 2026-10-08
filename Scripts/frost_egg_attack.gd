extends Node2D

@export var icicle_scene: PackedScene
@export var icicle_speed: float = 100
@export var icicle_damage: int = 5
@onready var attack_timer: Timer = $AttackTimer

var player: Node2D = null
var count = 8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	attack_timer.wait_time = 3
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_fire() == false:
		return
		
	fire()
	print("Frost Egg Attack!")
	attack_timer.start()


func fire() -> void:
	for i in range(count):
		# Divide TAU evenly by the total count to get evenly spaced angles
		var angle = (TAU / count) * i
		var spawn_dir = Vector2(cos(angle), sin(angle))
		
		var icicle = icicle_scene.instantiate()
		icicle.on_hit_damage = icicle_damage
		icicle.global_position = player.global_position # Positioned at the spawner
		icicle.direction = spawn_dir # Pass the direction vector to the projectile
		icicle.velocity = spawn_dir * icicle_speed
		get_tree().current_scene.add_child(icicle)
	
func can_fire() -> bool:
	return attack_timer.is_stopped()
		
