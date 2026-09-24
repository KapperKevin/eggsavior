extends Node2D

@export var pistol_data: GunData
@onready var muzzle: Marker2D = $Muzzle
# Called when the node enters the scene tree for the first time.
func shooting() -> void:
	var projectile = pistol_data.bullet_projectile.instantiate()
	projectile.global_position = muzzle.global_position
	var shoot_direction = transform.x
	projectile.velocity = shoot_direction * projectile.speed
	
	get_tree().current_scene.add_child(projectile)
	
