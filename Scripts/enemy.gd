extends CharacterBody2D

@export var spawned_enemy: EnemyData
@onready var sprite: Sprite2D = $Sprite2D

var current_health: int = 15 #Assinged as default in no EnemyData is found
var current_speed: int = 100 #Assinged as default in no EnemyData is found

func _ready() -> void:
	if spawned_enemy:
		sprite.texture = spawned_enemy.enemy_sprite
		current_health = spawned_enemy.enemy_hitpoints
		current_speed = spawned_enemy.enemy_speed
	else:
		print("No Enemy Data Available! Setting Default Stats.")
	
func take_damage(damage_recieved: int) -> void:
	current_health -= damage_recieved
	print("Enemy Recieved Damage! Damage taken: ", damage_recieved)
	if current_health <= 0:
		death()
	
func death() -> void:
	print("You have killed me ;(")
	queue_free()
	
