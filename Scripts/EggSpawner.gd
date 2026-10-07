class_name EggSpawner
extends Node

@export var all_eggs: Array[EggData] = []
@export var egg_scene: PackedScene

#temporary most likely
@onready var player: CharacterBody2D

var spawn_position: Vector2
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	spawn_egg.call_deferred()

func get_rarity_weight(rarity: EggData.EggRarity) -> int:
	match rarity:
		EggData.EggRarity.COMMON:
			return 60
		EggData.EggRarity.RARE:
			return 30
		EggData.EggRarity.MYTHIC:
			return 5
		EggData.EggRarity.CURSED:
			return 5
	return 10

func roll_random_egg() -> EggData:
	if all_eggs.is_empty():
		print("No Eggs to roll!")
		return null
	
	var total_weight: int = 0
	for egg in all_eggs:
		total_weight += get_rarity_weight(egg.rarity)
		
	var random_roll = randi_range(0, total_weight)
	
	var current_weight: int = 0
	for egg in all_eggs:
		current_weight += get_rarity_weight(egg.rarity)
		if random_roll < current_weight:
			print("Rolled egg: ", egg.egg_name)
			return egg
			
	return all_eggs[0]
	
# This function triggers when the button is pressed. Temporary Function
func _on_button_pressed() -> void:
	var rolled_egg = roll_random_egg()
	
	# Check if we actually got an egg (prevents crashes if the array is empty or broken)
	if rolled_egg != null:
		print("Successfully rolled: ", rolled_egg.egg_name)
		#Physical spawns the Egg
		var new_egg = egg_scene.instantiate()
		new_egg.possible_egg = rolled_egg
		new_egg.global_position = spawn_position
		get_tree().current_scene.add_child(new_egg)

	else:
		print("Error: No egg was returned from the roll!")

func spawn_egg() -> void:
	var markers = get_tree().get_nodes_in_group("egg_markers")
	if markers.is_empty():
		print("ERROR: No egg_markers found!")
	
	for marker in markers:
		if marker is Marker2D:
			var rolled_egg = roll_random_egg()
			if rolled_egg != null:
				var new_egg = egg_scene.instantiate()
				new_egg.possible_egg = rolled_egg
				get_tree().current_scene.add_child(new_egg)
				new_egg.global_position = marker.global_position
				print(new_egg.global_position)
				
