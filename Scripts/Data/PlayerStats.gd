class_name PlayerStats
extends Resource

@export_category("Base Stats")
@export var base_player_health: int = 6
@export var base_player_speed: float = 100.0
@export var Base_immunity_frames: float = 0.5

@export_category("Current Stats (Active)")
@export var current_player_health: int = 6:
		set(value):
			current_player_health = clamp(value, 0, base_player_health)
@export var current_immunity_frames: float = 0.5

@export_category("Active Buffs From Eggs")
@export var egg_damage_multiplier: float = 0
@export var egg_speed_multiplier: float = 0
@export var egg_extra_hitpoints: float = 0

@export_category("Eggs")
@export var current_eggs_held: Array[EggData] = []
var active_effect_nodes: Dictionary = {}

#This Function is only called when an Egg is Collected.
func apply_effect(given_egg: EggData) -> void:
	egg_extra_hitpoints += given_egg.hit_point
	current_eggs_held.append(given_egg)
	
	if given_egg.effect_type & EggData.EggType.STAT_EFFECT:
		set_stat_effect(given_egg)
		
	if given_egg.effect_type & EggData.EggType.PHYSICAL_EFFECT:
		handle_node_effect(given_egg, "physical")
		
	if given_egg.effect_type & EggData.EggType.TRIGGER_EFFECT:
		handle_node_effect(given_egg, "trigger")

#Handles if any Egg requires a physical node to be spawned to work.
func handle_node_effect(given_egg: EggData, effect_category: String) -> void:
	if active_effect_nodes.has(given_egg):
		#Egg is already held by player, therefore add a stack instead
		active_effect_nodes[given_egg]["stacks"] += 1
		var active_node = active_effect_nodes[given_egg]["node"]
		if active_node.has_method("add_stack"):
			active_node.add_stack()
	else:
		var scene_to_spawn: PackedScene = null
		
		if effect_category == "physical":
			scene_to_spawn = given_egg.physical_effect_scene
		elif effect_category == "trigger":
			scene_to_spawn = given_egg.trigger_effect_scene
			
		if scene_to_spawn != null:
			var temp_holder = scene_to_spawn.instantiate()
			var tree = Engine.get_main_loop() as SceneTree
			tree.current_scene.add_child(temp_holder)
			
			active_effect_nodes[given_egg] = {
				"node": temp_holder,
				"stacks": 1
			}
			print("Spawned new node effect for: ", given_egg.egg_name)

func set_stat_effect(given_egg: EggData) -> void:
	if given_egg.stat_effect_type & EggData.EggStatEffect.SPEED:
		egg_speed_multiplier += given_egg.speed_magnitude
		print("Applied Speed buff: ", given_egg.speed_magnitude)

	if given_egg.stat_effect_type & EggData.EggStatEffect.DAMAGE:
		egg_damage_multiplier += given_egg.damage_magnitude
		print("Applied Damage buff: ", given_egg.damage_magnitude)

#This Function is called when the Player takes damage.
func remove_egg() -> void:
	var temp_egg_holder = current_eggs_held[0]
	match temp_egg_holder.effect_type:
		EggData.EggType.STAT_EFFECT:
			remove_stat_effect(temp_egg_holder)
		EggData.EggType.PHYSICAL_EFFECT, EggData.EggType.TRIGGER_EFFECT:
			remove_physical_effect(temp_egg_holder)
	current_eggs_held.pop_front()

#Function is called via remove_egg() if Eggtype is STAT_EFFECT
func remove_stat_effect(lost_egg: EggData) -> void:
	if lost_egg.stat_effect_type & EggData.EggStatEffect.SPEED:
			egg_speed_multiplier -= lost_egg.speed_magnitude
			print("Lost Egg: Speed has Been Reduced by: ", lost_egg.speed_magnitude)
			
	if lost_egg.stat_effect_type & EggData.EggStatEffect.DAMAGE:
			egg_damage_multiplier -= lost_egg.damage_magnitude
			print("Lost Egg: Damage Reduced by: ", lost_egg.damage_magnitude)
			
#Function is called via remove_egg() if Eggtype is PHYSICAL_EFFECT
func remove_physical_effect(egg: EggData) -> void:
	if active_effect_nodes.has(egg):
				# Reduce the stack count
		active_effect_nodes[egg]["stacks"] -= 1
		var active_node = active_effect_nodes[egg]["node"]
				
				# Inform the node a stack was lost
		if active_node.has_method("remove_stack"):
			active_node.remove_stack()
					
				# IF STACKS HIT ZERO: Clean it up from the world entirely!
		if active_effect_nodes[egg]["stacks"] <= 0:
			if is_instance_valid(active_node):
				active_node.queue_free()
				active_effect_nodes.erase(egg)
				print("All stacks removed. Effect node destroyed.")
		else:
			print("Stack removed. Remaining stacks: ", active_effect_nodes[egg]["stacks"])

#Adding buffs via any Trigger Effect
func give_trigger_buff(buff_name: String, buff_value: float) -> void:
	match buff_name:
		"SPEED":
			egg_speed_multiplier += buff_value
		"DAMAGE":
			egg_damage_multiplier += buff_value

#Removing buffs from any Trigger effect
func remove_trigger_buff(buff_name: String, buff_value: float) -> void:
	match buff_name:
		"SPEED":
			egg_speed_multiplier -= buff_value
		"DAMAGE":
			egg_damage_multiplier -= buff_value

func heal(amount: int) -> void:
	current_player_health += amount
