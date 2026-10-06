extends CanvasLayer

@export var player_stats: PlayerStats

@onready var heart_container: HBoxContainer = $Control/HeartContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_hud()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_hud() -> void:
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
