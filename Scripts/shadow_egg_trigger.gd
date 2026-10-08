extends Node2D

@export var charge_required: int = 10
@export var speed_boost_multiplier: float = 0.5
@export var damage_boost_multiplier: float = 1.0
@export var shadow_sprite: Texture2D
@export var base_player_sprite: Texture2D 

var current_charge: int = 0

@onready var trigger_timer: Timer = $TriggerTimer


var is_shadow_active: bool = false
var player: Node2D = null

func _ready() -> void:
	print("Shadow Egg Charge At: ", current_charge)
	trigger_timer.wait_time = 5
	player = get_tree().get_first_node_in_group("player")
	GameEvents.player_dealt_damage.connect(add_charge)
	
	
func add_charge(amount: float) -> void:
	if is_shadow_active:
		return # Don't build charge while already in shadow state!
		
	current_charge += amount
	print("Shadow Charge: ", current_charge, "/", charge_required)
	
	if current_charge >= charge_required:
		trigger_shadow_state()

func trigger_shadow_state() -> void:
	is_shadow_active = true
	current_charge = 0
	print("--- SHADOW STATE ACTIVATED ---")
	player.get_node("Sprite2D").texture = shadow_sprite
	# Apply temporary stat boosts to PlayerStats
	player.stats.give_trigger_buff("SPEED", speed_boost_multiplier)
	player.stats.give_trigger_buff("DAMAGE", damage_boost_multiplier)
	
	#Duration of Shadow State
	trigger_timer.start()
	await trigger_timer.timeout
	end_shadow_state()

func end_shadow_state() -> void:
	is_shadow_active = false
	print("--- SHADOW STATE WORE OFF ---")
	player.get_node("Sprite2D").texture = base_player_sprite
	# Remove the temporary stat boosts
	player.stats.remove_trigger_buff("SPEED", speed_boost_multiplier)
	player.stats.remove_trigger_buff("DAMAGE", damage_boost_multiplier)
