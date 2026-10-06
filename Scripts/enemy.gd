class_name Enemy
extends CharacterBody2D

@export var spawned_enemy: EnemyData
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurt_box: Area2D = $HurtBox
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var current_health: int = 15 #Assinged as default in no EnemyData is found
var current_speed: int = 100 #Assinged as default in no EnemyData is found
var current_damage: int= 1

func _ready() -> void:
	hurt_box.body_entered.connect(_on_hurt_box_body_entered)
	#Setting the Stats of the Enemy from the Enemy Data
	if spawned_enemy:
		sprite.texture = spawned_enemy.enemy_sprite
		current_health = spawned_enemy.enemy_hitpoints
		current_speed = spawned_enemy.enemy_speed
	#If not EnemyData exits, goes with default stats
	else:
		print("No Enemy Data Available! Setting Default Stats.")

func take_damage(damage_recieved: int) -> void:
	current_health -= damage_recieved
	print("Enemy Recieved Damage! Damage taken: ", damage_recieved)
	if current_health <= 0:
		death()
	
func death() -> void:
	print("You have killed me ;( my speed was: ", current_speed)
	queue_free()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(current_damage)
		print("Player took Damage!")

func get_path_direction(target_pos: Vector2) -> Vector2:
	nav_agent.target_position = target_pos
	if nav_agent.is_navigation_finished():
		return Vector2.ZERO
		
	var current_pos = global_position
	var next_path_pos = nav_agent.get_next_path_position()
	return current_pos.direction_to(next_path_pos)
