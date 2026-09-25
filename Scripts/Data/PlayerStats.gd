class_name PlayerStats
extends Resource

@export_category("Base Stats")
@export var base_player_health: int = 1
@export var base_player_speed: float = 100.0
@export var Base_immunity_frames: float = 0.5

@export_category("Current Stats (Active)")
@export var current_player_health: int = 1
@export var current_player_speed: float = 100.0
@export var current_immunity_frames: float = 0.5

func apply_effect(given_egg: EggData) -> void:
	match given_egg.effect_type:
		EggData.EggType.PHYSICAL_EFFECT:
			set_physical_effect(given_egg)
		EggData.EggType.STAT_EFFECT:
			set_stat_effect(given_egg)
		

func set_stat_effect(given_egg: EggData) -> void:
	match given_egg.effect:
		EggData.EggStatEffect.NONE:
			print("This Egg has no Stat effect!")
		EggData.EggStatEffect.SPEED:
			current_player_speed = current_player_speed + (current_player_speed * given_egg.stat_effect)
			print("Egg has updated Speed!")
		EggData.EggStatEffect.DAMAGE:
			print("Egg has updated Damage!")

func set_physical_effect(given_egg: EggData) -> void:
	print("No physical effects yet")
