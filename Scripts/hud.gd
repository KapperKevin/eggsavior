extends CanvasLayer

@export var player_stats: PlayerStats

@onready var heart_container: HBoxContainer = $Control/HeartContainer
@onready var gold_label: Label = $Control/GoldCounter/Gold
@onready var ammo_label: Label = $Control/AmmoLabel

var player: Node2D = null
var current_weapon: Node2D = null
var current_gold: int = 0
var current_ammo: int = 0
var max_ammo: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	current_weapon = get_tree().get_first_node_in_group("weapon")
	update_hearts()
	update_gold(current_gold)
	update_ammo()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_hearts() -> void:
	var hearts = heart_container.get_children()
	
	for i in range(hearts.size()):
		var hp_for_this_heart = player_stats.current_player_health - (i * 2)
		var texture_rect = hearts[i] as TextureRect
		
		var atlas_tex = texture_rect.texture as AtlasTexture
		if atlas_tex:
			if hp_for_this_heart >= 2:
				atlas_tex.region = Rect2(0, 0, 32, 32)
			elif hp_for_this_heart == 1:
				atlas_tex.region = Rect2(32, 0, 32, 32)
			else:
				atlas_tex.region = Rect2(64, 0, 32, 32)

func update_gold(gold_recieved: int) -> void:
	current_gold += gold_recieved
	gold_label.text = str(current_gold)

func update_ammo() -> void:
	ammo_label.text = str(current_weapon.current_ammo) + "/" + str(current_weapon.gun_data.gun_max_ammo)
