extends Node2D

@export var gun_data: GunData
@export var players_stats: PlayerStats

@onready var muzzle: Marker2D = $Muzzle
@onready var attackTimer: Timer = $AttackTimer
@onready var reloadTimer: Timer = $ReloadTimer
@onready var current_ammo: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Setting the Fire Rate of the weapon
	attackTimer.wait_time = gun_data.gun_fire_rate
	#Setting the Reload speed of the wseapon
	reloadTimer.wait_time = gun_data.gun_reload_speed
	reloadTimer.timeout.connect(reload)
	#Setting Ammo of weapon
	current_ammo = gun_data.gun_ammo

#This Function is called from player.gd when left mouse is pressed
func shooting() -> void:
	if can_shoot() == false:
		return

	#This Block of code runs if can_shoot() == true
	attackTimer.start()

	
	var projectile = gun_data.bullet_projectile.instantiate()
	
	#Adds Necessary Effects to Bullet
	projectile.current_bounces = gun_data.bullet_bounces
	var final_damage = gun_data.gun_damage + (gun_data.gun_damage * players_stats.egg_damage_multiplier)
	projectile.on_hit_damage = final_damage
	
	#Spawns and puts velocity into bullet projectile
	projectile.global_position = muzzle.global_position
	var shoot_direction = muzzle.global_transform.x.normalized()
	projectile.velocity = shoot_direction * gun_data.bullet_speed
	projectile.rotation = shoot_direction.angle()
	
	
	
	get_tree().current_scene.add_child(projectile)
	
	#Counts down ammo and Checks for Reload
	current_ammo -= 1
	get_tree().get_first_node_in_group("hud").update_ammo()
	if current_ammo == 0:
		reloadTimer.start()
		return

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		if current_ammo == gun_data.gun_max_ammo or !reloadTimer.is_stopped():
			print("Can't Reload. Either at Max Ammo OR Reload in progress already")
		else:
			print("Reloading...")
			reloadTimer.start()
			return

#checks if the player is allowed to shoot
func can_shoot() -> bool:
	return attackTimer.is_stopped() and reloadTimer.is_stopped()

#Is called when reloadTimer has ended or When Player reloads manually
func reload() -> void:
	current_ammo = gun_data.gun_ammo
	get_tree().get_first_node_in_group("hud").update_ammo()
