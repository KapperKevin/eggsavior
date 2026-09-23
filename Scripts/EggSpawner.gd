class_name EggSpawner
extends Node

@export var all_eggs: Array[Egg] = []

func get_rarity_weight(rarity: Egg.EggRarity) -> int:
	match rarity:
		Egg.EggRarity.COMMON:
			return 60
		Egg.EggRarity.RARE:
			return 30
		Egg.EggRarity.MYTHIC:
			return 5
		Egg.EggRarity.CURSED:
			return 5
	return 10

func roll_random_egg() -> Egg:
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
	
# This function triggers when the button is pressed
func _on_button_pressed() -> void:
	var rolled_egg = roll_random_egg()
	
	# Check if we actually got an egg (prevents crashes if the array is empty or broken)
	if rolled_egg != null:
		print("Successfully rolled: ", rolled_egg.egg_name)
	else:
		print("Error: No egg was returned from the roll!")
