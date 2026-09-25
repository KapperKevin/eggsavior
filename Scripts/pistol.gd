extends Node2D

@export var pistol_data: GunData
@onready var muzzle: Marker2D = $Muzzle
@onready var attackTimer: Timer = $AttackTimer
@onready var reloadTimer: Timer = $ReloadTimer
@onready var current_ammo: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Setting the Fire Rate of the weapon
	attackTimer.wait_time = pistol_data.gun_fire_rate
	#Setting the Reload speed of the weapon
	reloadTimer.wait_time = pistol_data.gun_reload_speed
	reloadTimer.timeout.connect(_on_reload_finished)
	#Setting Ammo of weapon
	current_ammo = pistol_data.gun_ammo

#This Function is called from player.gd when left mouse is pressed
func shooting() -> void:
	if can_shoot() == false:
		return

	#This Block of code runs if can_shoot() == true
	attackTimer.start()

	#Spawns and puts velocity into bullet projectile
	var projectile = pistol_data.bullet_projectile.instantiate()
	projectile.global_position = muzzle.global_position
	
	var shoot_direction = global_transform.x
	projectile.velocity = shoot_direction * pistol_data.bullet_velocity
	projectile.rotation = shoot_direction.angle()
	
	get_tree().current_scene.add_child(projectile)
	
	#Counts down ammo and Checks for Reload
	current_ammo -= 1
	if current_ammo == 0:
		print("reloading...")
		reloadTimer.start()
		return

#checks if the player is allowed to shoot
func can_shoot() -> bool:
	return attackTimer.is_stopped() and reloadTimer.is_stopped()

#Is called when reloadTimer has ended
func _on_reload_finished() -> void:
	print("Reloaded!")
	current_ammo = pistol_data.gun_ammo
