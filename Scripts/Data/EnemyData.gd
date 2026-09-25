class_name EnemyData
extends Resource

@export_category("Stats")
@export var enemy_hitpoints: int = 1
@export var enemy_damage: int = 1
@export var enemy_speed: int = 100
@export var aggro_range: int = 0 #Not useful for now

@export_category("Visual")
@export var enemy_sprite: Texture2D
