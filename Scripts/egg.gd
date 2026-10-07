extends Area2D

@export var possible_egg: EggData
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_label: Label = $Label

var player_in_range = false
var player_body: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = possible_egg.egg_sprite
	if interact_label:
		interact_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_body = body
		player_in_range = true
		if interact_label:
			interact_label.visible = true
		#Applies effect to the player

		
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if interact_label:
			interact_label.visible = false
			
func _unhandled_input(event: InputEvent) -> void:
	# Only listen for the button press if the player is actually standing close enough
	if player_in_range and event.is_action_pressed("interact"):
		pick_up()

func pick_up() -> void:
	print("Egg collected!")
	player_body.stats.apply_effect(possible_egg)
	player_body.speed = player_body.stats.current_player_speed
	queue_free()
