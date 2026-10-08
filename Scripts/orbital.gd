extends Area2D

@export var damage: int = 10
@export var rotation_speed: float = 3.0
@export var orbit_radius: float = 60.0

var angle: float = 0.0
var player: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player:
		return
	
	angle += rotation_speed * delta
	var offset = Vector2(cos(angle), sin(angle)) * orbit_radius
	global_position = player.global_position + offset
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"): # Or check for a specific damage function
		if body.has_method("take_damage"):
			body.take_damage(damage)
