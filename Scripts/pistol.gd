extends Node2D

@export var pistol_data: GunData

# Called when the node enters the scene tree for the first time.
func shooting() -> void:
	var projectile = pistol_data.bullet_projectile.instantiate()
	add_child(projectile)
	print("Bullet Added")
