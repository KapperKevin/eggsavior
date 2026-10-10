extends Area2D

@export var damage: int = 10
@export var rotation_speed: float = 3.0
@export var orbit_radius: float = 60.0

var base_angle: float = 0.0
var player: Node2D = null

# Static or shared array tracking all active orbital instances in the world
static var active_orbitals: Array[Node2D] = []

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	# Register this instance into our global tracker array
	if not active_orbitals.has(self):
		active_orbitals.append(self)

func _process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	# Rotate the base angle over time
	base_angle += rotation_speed * delta
	
	# ONLY the first item in the array calculates and updates positions for EVERYONE, 
	# preventing math conflicts!
	if active_orbitals.is_empty() or active_orbitals[0] != self:
		return
		
	var total = active_orbitals.size()
	for i in range(total):
		var node = active_orbitals[i]
		if not is_instance_valid(node):
			continue
			
		# Even spacing math: Divides 360 degrees (TAU) evenly by total active count
		var angle_offset = base_angle + (TAU / total) * i
		var offset = Vector2(cos(angle_offset), sin(angle_offset)) * orbit_radius
		node.global_position = player.global_position + offset

# --- STACK HOOKS CALLED BY PLAYERSTATS ---

func add_stack() -> void:
	# Duplicate the scene directly
	var clone = duplicate() as Node2D
	get_tree().current_scene.add_child(clone)
	print("Orbital stack added! Total instances: ", active_orbitals.size())

func remove_stack() -> void:
	# Remove the last instance from our tracking list and free it
	if active_orbitals.size() > 1:
		var node_to_remove = active_orbitals.pop_back()
		if is_instance_valid(node_to_remove) and node_to_remove != self:
			node_to_remove.queue_free()

func _exit_tree() -> void:
	# Clean up the tracker array when nodes are freed
	active_orbitals.erase(self)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"): # Or check for a specific damage function
		if body.has_method("take_damage"):
			body.take_damage(damage)
