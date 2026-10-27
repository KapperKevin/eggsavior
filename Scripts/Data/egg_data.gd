class_name EggData
extends Resource

#This is a BitFlag, and allows for MULTIPLE enum value to be active at once.
enum EggType {
	STAT_EFFECT = 1,
	PHYSICAL_EFFECT = 2,
	TRIGGER_EFFECT = 4
}
enum EggRarity {COMMON, RARE, MYTHIC, QUEST, CURSED}
enum EggStatEffect {
	NONE = 0,
	SPEED = 1,
	DAMAGE = 2,
	FIRE_RATE = 4,
	PROJECTILE_VELOCITY = 8
}
enum EggPhysicalEffect { NONE, ORBITAL, FAMILIAR, PERIODIC_SHOOTER }

@export_category("Basic Information")
@export var egg_name: String = "None"
@export var egg_sprite: Texture2D
@export var gold_value: int = 0
@export var rep_value: int = 0
@export var rarity: EggRarity = EggRarity.COMMON
@export_flags("Stat Effect", "Physical Effect", "Trigger Effect") var effect_type: int = 0

@export_category("Stat Effects Settings")
#The magnitudes are scaled in percentages. 0.2 = 20% buff | 1.0 = 100% buff | -0.2 = 20% debuff
@export var speed_magnitude: float = 0
@export var damage_magnitude: float = 0
@export var fire_rate_magnitude: float = 0
@export var projectile_velocity_magnitude: float = 0
@export var hit_point: int = 1
@export_flags("Speed", "Damage", "Fire Rate", "Projectile Velocity") var stat_effect_type: int = 0

@export_category("Physical Effect Settings")
@export var physical_effect: EggPhysicalEffect = EggPhysicalEffect.NONE
@export var physical_effect_scene: PackedScene

@export_category("Trigger Effect Settings")
@export var trigger_effect_scene: PackedScene

@export_category("Visual Effects")
@export var feather_color: Color = Color.WHITE
@export var overlay_texture: Texture2D = null
