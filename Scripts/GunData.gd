class_name GunData
extends Resource

@export_category("Bullet Stats")
@export var gun_damage: int = 1
@export var gun_fire_rate: float = 0.5
@export var gun_ammo: int = 1
@export var gun_reload_speed: float = 1
@export var gun_overheat: int = 0
@export var bullet_velocity: int = 1
@export var bullet_pierce: int = 0
@export var bullet_bounces: int = 0

@export_category("Visual")
@export var bullet_projectile: PackedScene
@export var firing_animation: Animation
