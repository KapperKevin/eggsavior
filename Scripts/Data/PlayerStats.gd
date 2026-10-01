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

func apply_effect(given_egg: EggData) -> void:
	egg_extra_hitpoints += given_egg.hit_point
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
			egg_speed_mutiplier += given_egg.stat_effect
			print("Egg has updated Speed! Mutiplier: ", egg_speed_mutiplier)
		EggData.EggStatEffect.DAMAGE:
			egg_damage_mutiplier += given_egg.stat_effect
			print("Egg has updated Damage! Mutiplier: ", egg_damage_mutiplier)

func set_physical_effect(given_egg: EggData) -> void:
	print("No physical effects yet")

func heal(amount: int) -> void:
	current_player_health += amount
