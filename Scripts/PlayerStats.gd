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
