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
@export var current_player_speed: float = 100.0
@export var current_immunity_frames: float = 0.5

@export_category("Active Buffs From Eggs")
@export var egg_damage_mutiplier: float = 0
@export var egg_speed_mutiplier: float = 0
@export var egg_extra_hitpoints: float = 0

@export_category("Eggs")
@export var current_eggs_held: Array[EggData] = []
var active_effect_nodes: Dictionary = {}

#This Function is only called when an Egg is Collected.
func apply_effect(given_egg: EggData) -> void:
	egg_extra_hitpoints += given_egg.hit_point
	current_eggs_held.append(given_egg)
	match given_egg.effect_type:
		EggData.EggType.PHYSICAL_EFFECT:
			if active_effect_nodes.has(given_egg):
				# IT ALREADY EXISTS: Just upgrade/add a stack!
				active_effect_nodes[given_egg]["stacks"] += 1
				var active_node = active_effect_nodes[given_egg]["node"]
				if active_node.has_method("add_stack"):
					active_node.add_stack()
			else:
				set_physical_effect(given_egg)
		EggData.EggType.STAT_EFFECT:
			set_stat_effect(given_egg)
		EggData.EggType.TRIGGER_EFFECT:
			if active_effect_nodes.has(given_egg):
				# IT ALREADY EXISTS: Just upgrade/add a stack!
				active_effect_nodes[given_egg]["stacks"] += 1
				var active_node = active_effect_nodes[given_egg]["node"]
				if active_node.has_method("add_stack"):
					active_node.add_stack()
			else:
				set_trigger_effect(given_egg)
		

func set_stat_effect(given_egg: EggData) -> void:
	match given_egg.effect:
		EggData.EggStatEffect.NONE:
			print("This Egg has no Stat effect!")
		EggData.EggStatEffect.SPEED:
			current_player_speed = current_player_speed + (current_player_speed * given_egg.stat_effect)
			egg_speed_mutiplier += given_egg.stat_effect
			print("Egg has updated Speed! Mutiplier: ", egg_speed_mutiplier)
		EggData.EggStatEffect.DAMAGE:
			egg_damage_mutiplier += given_egg.stat_effect
			print("Egg has updated Damage! Mutiplier: ", egg_damage_mutiplier)

func set_physical_effect(given_egg: EggData) -> void:
	match given_egg.physical_effect:
		EggData.EggPhysicalEffect.NONE:
			print("This Egg has No Physical Effect!")
		EggData.EggPhysicalEffect.ORBITAL, EggData.EggPhysicalEffect.FAMILIAR, EggData.EggPhysicalEffect.PERIODIC_SHOOTER:
			var temp_holder = given_egg.physical_effect_scene.instantiate()
			var tree = Engine.get_main_loop() as SceneTree
			tree.current_scene.add_child(temp_holder)
			active_effect_nodes[given_egg] = {
					"node": temp_holder,
					"stacks": 1
				}
			print("Added Physical Effect")
			
func set_trigger_effect(given_egg: EggData) -> void:
	var temp_holder = given_egg.trigger_effect_scene.instantiate()
	var tree = Engine.get_main_loop() as SceneTree
	tree.current_scene.add_child(temp_holder)
	active_effect_nodes[given_egg] = {
			"node": temp_holder,
			"stacks": 1
		}	

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
func remove_stat_effect(egg: EggData) -> void:
	match egg.effect:
		EggData.EggStatEffect.NONE:
			print("Removed No Stat Effect. Egg had None")
		EggData.EggStatEffect.SPEED:
			current_player_speed = current_player_speed / (1.0 + egg.stat_effect)
			egg_speed_mutiplier -= egg.stat_effect
			print("Lost Egg: Speed has Been Reduced by: ", egg.stat_effect)
		EggData.EggStatEffect.DAMAGE:
			egg_damage_mutiplier -= egg.stat_effect
			print("Lost Egg: Damage Reduced by: ", egg.stat_effect)
			
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
			current_player_speed = current_player_speed + (current_player_speed * buff_value)
			egg_speed_mutiplier += buff_value
		"DAMAGE":
			egg_damage_mutiplier += buff_value

#Removing buffs from any Trigger effect
func remove_trigger_buff(buff_name: String, buff_value: float) -> void:
	match buff_name:
		"SPEED":
			current_player_speed = current_player_speed / (1.0 + buff_value)
			egg_speed_mutiplier -= buff_value
		"DAMAGE":
			egg_damage_mutiplier -= buff_value

func heal(amount: int) -> void:
	current_player_health += amount
