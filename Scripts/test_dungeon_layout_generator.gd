extends Node2D

var cell_size := 64.0
const MARGIN := Vector2(40, 40)

@export var dungeon_size := Vector2i(16,16)
@export var path_length := 8
@export var branch_chance := 0.5
@export var max_branch_length := 3
@export var loop_count := 2
@export var max_egg_rooms := 3

@export var use_fixed_seed := false
@export var fixed_seed := 12345
 
var gen := dungeon_layout_generator.new()
var layout: Array[dungeon_layout_generator.Room] = []

func _ready() -> void:
	get_viewport().size_changed.connect(queue_redraw)
	_regenerate()

func _regenerate() -> void:
	var seed_value := fixed_seed if use_fixed_seed else randi()
	print("Seed: ", seed_value)
	layout = gen.generate(seed_value, dungeon_size, path_length, max_branch_length, branch_chance, loop_count, max_egg_rooms)
	queue_redraw()

func _draw() -> void:
	_update_scale()
	var font := ThemeDB.fallback_font
 
	for room in layout:
		var rect := Rect2(
			MARGIN + Vector2(room.origin) * cell_size, Vector2(room.size) * cell_size).grow(-3.0)
		draw_rect(rect, _color_for(room.type))
		draw_rect(rect, Color.BLACK, false, 2.0)
		draw_string(font, rect.position + Vector2(6, 18), str(room.distance),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
 
	for i in range(1, gen.critical_path.size()):
		draw_line(
			_room_center(gen.critical_path[i - 1]),
			_room_center(gen.critical_path[i]),
			Color.YELLOW, 3.0)
 
	for room in layout:
		for door in room.doors:
			var pos := MARGIN + (Vector2(door.cell) + Vector2(0.5, 0.5)) * cell_size \
					+ Vector2(door.dir) * cell_size * 0.5
			draw_circle(pos, 7.0, Color.WHITE)
			draw_circle(pos, 7.0, Color.BLACK, false, 2.0)

func _update_scale() -> void:
	var avail := get_viewport_rect().size - MARGIN * 2.0
	cell_size = minf(avail.x / dungeon_size.x, avail.y / dungeon_size.y)
	
func _room_center(room: dungeon_layout_generator.Room) -> Vector2:
	return MARGIN + (Vector2(room.origin) + Vector2(room.size) * 0.5) * cell_size

func _color_for(type: int) -> Color:
	match type:
		dungeon_layout_generator.RoomType.START:
			return Color(0.25, 0.65, 0.3)
		dungeon_layout_generator.RoomType.BOSS:
			return Color(0.75, 0.2, 0.2)
		dungeon_layout_generator.RoomType.EGG:
			return Color(0.85, 0.7, 0.2)
	return Color(0.3, 0.4, 0.6)
