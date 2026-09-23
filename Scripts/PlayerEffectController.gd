extends Node

@export var all_eggs: Array[Egg]

@onready var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node("player")
