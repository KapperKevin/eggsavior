class_name Egg
extends Resource

enum EggType {STAT_EFFECT, PHYSICAL_EFFECT}
enum EggRarity {COMMON, RARE, MYTHIC, QUEST, CURSED}
enum EggStatEffect {NONE, SPEED, DAMAGE}


@export var egg_name: String = "None"
@export var egg_sprite: Texture2D
@export var gold_value: int = 0
@export var rep_value: int = 0
@export var stat_effect: float = 0.0
@export var hit_point: int = 1
@export var effect_type: EggType = EggType.STAT_EFFECT
@export var effect: EggStatEffect = EggStatEffect.NONE
@export var rarity: EggRarity = EggRarity.COMMON
@export var egg_scene: PackedScene
