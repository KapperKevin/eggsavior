extends Node2D

@export var gun_data: GunData
@export var players_stats: PlayerStats

@onready var muzzle: Marker2D = $Muzzle
@onready var attackTimer: Timer = $AttackTimer
@onready var current_ammo: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attackTimer.wait_time = gun_data.gun_fire_rate
	current_ammo = gun_data.gun_ammo

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shooting() -> void:
	if can_shoot() == false:
		return

	#This Block of code runs if can_shoot() == true
	attackTimer.start()

	
	var projectile = gun_data.bullet_projectile.instantiate()
	#Adds Necessary Effects to Bullet
	var final_damage = gun_data.gun_damage + (gun_data.gun_damage * players_stats.egg_damage_multiplier)
	projectile.on_hit_damage = final_damage
	var shoot_direction = muzzle.global_transform.x.normalized()
	projectile.velocity = shoot_direction * gun_data.bullet_speed
	#Handles Projectile Positioning
	projectile.global_position = muzzle.global_position
	get_tree().current_scene.add_child(projectile)
	#Sets Color of the Projectile
	projectile.setup_color(calculate_feather_color())
	
func can_shoot() -> bool:
	return attackTimer.is_stopped()


func calculate_feather_color() -> Color:
	if not players_stats or players_stats.current_eggs_held.is_empty():
		return Color.WHITE
	
	#Variables to temporarily hold colors for RGB
	var blended_r: float = 0.0
	var blended_g: float = 0.0
	var blended_b: float = 0.0
	var tint_count: int = 0 #This keeps track of the amount of Eggs actually change color.
	
	for egg in players_stats.current_eggs_held:
		if egg and egg.feather_color != Color.WHITE:
			blended_r += egg.feather_color.r
			blended_g += egg.feather_color.g
			blended_b += egg.feather_color.b
			tint_count += 1
	
	#Checks if none of the Eggs change the color. If none, return WHITE
	if tint_count == 0:
		return Color.WHITE
	
	return Color(blended_r / tint_count, blended_g / tint_count, blended_b / tint_count)
