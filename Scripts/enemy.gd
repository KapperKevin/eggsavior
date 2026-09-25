extends CharacterBody2D

@export var spawned_enemy: EnemyData
@onready var sprite: Sprite2D = $Sprite2D

var current_health: int
var current_speed: int

func _ready() -> void:
	sprite.texture = spawned_enemy.enemy_sprite
	current_health = spawned_enemy.enemy_hitpoints
	current_speed = spawned_enemy.enemy_speed
	
