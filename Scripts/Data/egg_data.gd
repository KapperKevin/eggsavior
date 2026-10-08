class_name EggData
extends Resource

enum EggType {STAT_EFFECT, PHYSICAL_EFFECT, TRIGGER_EFFECT}
enum EggRarity {COMMON, RARE, MYTHIC, QUEST, CURSED}
enum EggStatEffect {NONE, SPEED, DAMAGE}
enum EggPhysicalEffect { NONE, ORBITAL, FAMILIAR, PERIODIC_SHOOTER }

@export_category("Basic Information")
@export var egg_name: String = "None"
@export var egg_sprite: Texture2D
@export var gold_value: int = 0
@export var rep_value: int = 0
@export var rarity: EggRarity = EggRarity.COMMON
@export var effect_type: EggType = EggType.STAT_EFFECT

@export_category("Stat Effects Settings")
@export var stat_effect: float = 0.0
@export var hit_point: int = 1
@export var effect: EggStatEffect = EggStatEffect.NONE

@export_category("Physical Effect Settings")
@export var physical_effect: EggPhysicalEffect = EggPhysicalEffect.NONE
@export var physical_effect_scene: PackedScene

@export_category("Trigger Effect Settings")
@export var trigger_effect_scene: PackedScene
