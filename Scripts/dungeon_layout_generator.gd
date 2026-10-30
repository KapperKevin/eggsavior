# Grid-based dungeon layout generator
#
# DETAILS
# Rooms (1x1,1x2,2x1,2x2) occupy cells in a rectangular grid.
# Cells are simply represented as position vectors, they are not their own object/class.
# Adjacent rooms are not necessarily connected via doors.
#
# ALGORITHM STEPS
# 1. Generate the main/critical path (start to exit).
# 2. Attempt to generate branching paths from the critical path.
# 3. Attempt to add loops to the dungeon so it doesn't feel linear.
# 4. Assign a RoomType to each Room.
#
# TO DO LIST
# - Implement new logic for assigning/placing Egg Rooms
#	- Currently they are only placed at dead-ends

class_name dungeon_layout_generator
extends RefCounted # Object is freed from memory when not in use

# Constraints
const MAX_ROOM_WIDTH := 2
const MAX_ROOM_HEIGHT := 2
const MAX_ATTEMPTS := 50		# How many times the script will attempt to build a valid critical path
const MAX_BUDGET := 3000		# Alloted "effort" per attempt

# Relative directions
const UP := Vector2i(0,-1)
const DOWN := Vector2i(0,1)
const LEFT := Vector2i(-1,0)
const RIGHT := Vector2i(1,0)
const DIRS: Array[Vector2i] = [UP, DOWN, LEFT, RIGHT]

# Room enums
enum RoomType {
	EMPTY,
	START,
	EXIT,
	NORMAL,
	EGG,
	BOSS
}
enum RoomSize {
	SMALL,
	WIDE,
	TALL,
	BIG
}

# Dictionary of room sizes
var room_sizes := {
	RoomSize.SMALL: 	Vector2i(1,1),
	RoomSize.TALL: 		Vector2i(1,2),
	RoomSize.WIDE: 		Vector2i(2,1),
	RoomSize.BIG:		Vector2i(2,2)
}

# Dictionary of room weights for dungeon generation
var room_weights := {
	RoomSize.SMALL: 	5.0,
	RoomSize.TALL: 		2.0,
	RoomSize.WIDE: 		2.0,
	RoomSize.BIG:		1.0
}

# Pairs of Doors connect two Rooms
class Door:
	var cell: Vector2i			# Absolute coordinates of this door's cell
	var local_cell: Vector2i	# Coordinates relative to the room's origin cell
	var dir: Vector2i			# Direction in which this door leads
	var target_room_id: int 	# ID of the room of the opposite door

# Rooms occupy cells in the dungeon grid
class Room:
	var id: int						# ID of this Room
	var origin: Vector2i 			# Absolute coordinates of the cell of the room's top left corner
	var size: Vector2i				# Ex. (1,1), (1,2), (2,1), (2,2)
	var type: int = RoomType.EMPTY	# Type of Room; defaults to EMPTY
	var is_critical: bool = false	# Is the room on the critical path to the exit?
	var distance: int				# Number of rooms away from the starting room
	var doors: Array[Door] = [] 	# Doors belonging to this Room
	
	## Returns the absolute coordinates of all cells occupied by this Room
	func cells() -> Array[Vector2i]:
		var room_cells : Array[Vector2i] = []
		for x in self.size.x:
			for y in self.size.y:
				room_cells.append(self.origin + Vector2i(x,y))
		return room_cells
	
# ------------ DUNGEON LAYOUT GENERATION -----------------
var rng := RandomNumberGenerator.new()
var dungeon_size: Vector2i
var rooms: Array[Room] = []					# All Rooms (Room.id equals the Room's index in this array)
var cells_to_rooms: Dictionary = {}			# Associates each cell with a room
var critical_path: Array[Room] = []			# Rooms of the critical path
var max_branch_length = 0					# Max number of rooms a side room can be from the critical path
var _budget := 0		

func generate(
		seed_value: int,
		dg_size: Vector2i,
		path_length: int,
		branch_length: int,
		branch_chance: float,
		loop_count: int,
		egg_rooms: int) -> Array[Room]:
	rng.seed = seed_value
	dungeon_size = dg_size
	max_branch_length = branch_length
	_reset()

	if not _build_critical_path(path_length):
		push_warning("DungeonLayoutGenerator: could not fit critical path; try a bigger grid or a shorter path.")
		_reset()
		return rooms
	_add_branches(branch_chance, max_branch_length)
	_add_loops(loop_count)
	_compute_distances()
	_assign_types(egg_rooms)
	return rooms

## Attempts to build a path of Rooms from start to exit
func _build_critical_path(length: int) -> bool:
	for _i in MAX_ATTEMPTS:
		_reset()
		_budget = MAX_BUDGET # Each attempt gets a fresh budget
		
		# Chooses a random cell as the starting room
		var start_cell := Vector2i(
			rng.randi_range(0, dungeon_size.x - 1),
			rng.randi_range(0, dungeon_size.y - 1))
		var start := _place(start_cell, Vector2i(1, 1))
		var path: Array[Room] = [start]
		
		if _extend_path(path, length):
			for i in range(1, path.size()):
				_connect(path[i - 1], path[i])
			for room in path:
				room.is_critical = true
			critical_path = path
			return true
	return false

## Attempts to extend a path to a given length (using DFS)
func _extend_path(path: Array[Room], length: int) -> bool:
	if path.size() >= length:	# If the path is already the required length (or greater)
		return true
	_budget -= 1				# Reduce the number of tries
	if _budget <= 0:			# If path generation takes too long
		return false
	
	var current := path[-1]			# Current Room at the end of the path
	var sizes: Array[Vector2i] = [] # Possible size for the next Room
	
	# If one more Room must be added, add a small Room for the exit.
	# Otherwise add a Room of a random size.
	if path.size() == length - 1:
		sizes.append(room_sizes[RoomSize.SMALL])
	else:
		sizes = _weighted_size_order()
	for size in sizes:
		var origins := _placements(current, size)
		_shuffle(origins)
		for origin in origins:
			var room := _place(origin, size)
			path.append(room)
			if _extend_path(path, length): # Recursion
				return true
			
			# Undo the previously added room and try another if path generation failed
			path.pop_back()
			_unplace(room)
	return false

## Attempts to create branching paths from the critical path between the Start and Exit Rooms
func _add_branches(chance: float, max_len: int) -> void:
	for i in range(1, critical_path.size() - 1): # Skip start and exit Rooms
		if rng.randf() <= chance:
			_grow_branch(critical_path[i], rng.randi_range(1, max_len))

func _grow_branch(anchor: Room, length: int) -> void:
	var current := anchor
	for _i in length:
		var placed := false
		for size in _weighted_size_order():
			var origins := _placements(current, size)
			if origins.is_empty():
				continue
			var room := _place(origins[rng.randi() % origins.size()], size)
			_connect(current, room)
			current = room
			placed = true
			break
		if not placed: # Return if the branch cannot be extended any further
			return
 
## Connects Rooms that we not previously connected
func _add_loops(count: int) -> void:
	var end := critical_path[-1]
	var pairs := {}  # Vector2i (min_id, max_id) -> Array [Room, Room]
	for room in rooms:
		for cell in room.cells():
			# Check only 2 perpendicular directions to avoid duplicate entries.
			# Suppose Rooms A and B are side-by-side. From a Room A cell we check right and find Room B.
			# Then, it is unnecessary to check left from Room B cells because we already have the pair
			# of adjacent Rooms A and B saved in our dictionary.
			for d in [RIGHT, DOWN]:
				var other = cells_to_rooms.get(cell + d)
				if other == null or other == room: # If the adjacent cell is OOB or in the same Room
					continue
				if room == end or other == end: # If either Room is the end of the critical path
					continue
				if _are_connected(room, other): # If the pair of Rooms are already connected
					continue
				var key := Vector2i(mini(room.id, other.id), maxi(room.id, other.id))
				pairs[key] = [room, other]
	var candidates: Array = pairs.values()
	_shuffle(candidates)
	for i in mini(count, candidates.size()):
		_connect(candidates[i][0], candidates[i][1])

## Determines distances (in number of Rooms) of each Room from the START Room (using BFS)
func _compute_distances() -> void:
	var start := critical_path[0]
	start.distance = 0
	var queue: Array[Room] = [start]
	var seen := {start.id: true}
	
	while not queue.is_empty():
		var cur: Room = queue.pop_front()
		for door in cur.doors:
			var next := rooms[door.target_room_id]
			if not seen.has(next.id):
				seen[next.id] = true
				next.distance = cur.distance + 1
				queue.append(next)

## Sets Room types for every Room in the dungeon
func _assign_types(egg_count: int) -> void:
	critical_path[0].type = RoomType.START
	critical_path[-1].type = RoomType.EXIT
 
	# Egg Rooms are at dead ends.
	var dead_ends: Array = []
	for room in rooms:
		if room.doors.size() == 1 and room.type == RoomType.EMPTY:
			dead_ends.append(room)
			
	dead_ends.sort_custom( # Sort Rooms in the dead_ends array by distance from the START Room
		func(a, b): 
			return a.distance > b.distance
	)
			
	for i in mini(egg_count, dead_ends.size()):
		dead_ends[i].type = RoomType.EGG

## Returns all possible origin cells where a room of `size` fits on free cells 
## and shares an edge with Room 'anchor'
func _placements(anchor: Room, size: Vector2i) -> Array[Vector2i]:
	var found := {}	# Storing info in a dictionary avoids duplicate entries for a given cell
	for cell in anchor.cells():
		for d in DIRS:
			var n := cell + d	# 'n' is a cell adjacent to a cell of 'anchor'
			
			# Skip prospective cell 'n' if it is out of bounds or already occupied
			if not _in_bounds(n) or cells_to_rooms.has(n):
				continue
				
			# Finds every Room position that covers cell n.
			for ox in size.x:
				for oy in size.y:
					var origin := n - Vector2i(ox, oy)
					if not found.has(origin) and _cells_free(origin, size):
						found[origin] = true
	var out: Array[Vector2i] = []
	for key in found:
		out.append(key)
	return out

## Checks if all cells in a given region (represented by 'origin' and 'size') are free
func _cells_free(origin: Vector2i, size: Vector2i) -> bool:
	for y in size.y:
		for x in size.x:
			var c := origin + Vector2i(x, y)
			if not _in_bounds(c) or cells_to_rooms.has(c):
				return false
	return true

## Creates and returns a Room with the given origin cell and size.
## Does not check if the cell already belongs to a Room.
func _place(origin: Vector2i, size: Vector2i) -> Room:
	var room := Room.new()
	room.id = rooms.size()
	room.origin = origin
	room.size = size
	rooms.append(room)
	for cell in room.cells():
		cells_to_rooms[cell] = room
	return room

## Removes the most recent Room.
func _unplace(room: Room) -> void:
	for cell in room.cells():
		cells_to_rooms.erase(cell)
	rooms.erase(room)

## Adds a pair of Doors on a random shared edge between two adjacent Rooms.
func _connect(a: Room, b: Room) -> void:
	var edges := _shared_edges(a, b)
	if edges.is_empty():
		return
		
	var edge: Array = edges[rng.randi() % edges.size()] # Obtain a random edge
	var cell_a: Vector2i = edge[0]
	var dir: Vector2i = edge[1]
	a.doors.append(_make_door(a, cell_a, dir, b))
	b.doors.append(_make_door(b, cell_a + dir, -dir, a))

## Returns an array of edges shared between Rooms 'a' and 'b'.
## Edges are represented as arrays with 2 elements (edge[0] is a cell; edge[1] is a direction).
func _shared_edges(a: Room, b: Room) -> Array:
	var edges: Array = []
	for cell in a.cells():
		for d in DIRS:
			if cells_to_rooms.get(cell + d) == b:
				edges.append([cell, d])
	return edges

## Returns a Door object
func _make_door(room: Room, cell: Vector2i, dir: Vector2i, target: Room) -> Door:
	var door := Door.new()
	door.cell = cell
	door.local_cell = cell - room.origin
	door.dir = dir
	door.target_room_id = target.id
	return door

## Determines if Rooms 'a' and 'b' are connected.
func _are_connected(a: Room, b: Room) -> bool:
	for door in a.doors:
		if door.target_room_id == b.id:
			return true
	return false


## Determines if a Room has a Door in a particular location/direction
func _has_door(room: Room, cell: Vector2i, dir: Vector2i) -> bool:
	for door in room.doors:
		if door.cell == cell and door.dir == dir:
			return true
	return false

## Resets dungeon variables
func _reset() -> void:
	rooms.clear()
	cells_to_rooms.clear()
	critical_path.clear()

## Checks if a cell is in bounds
func _in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < dungeon_size.x and p.y < dungeon_size.y

## Randomize the order in which the script will attempt
## to add rooms of different sizes to the end of a path.
func _weighted_size_order() -> Array[Vector2i]:
	var pool: Array = room_weights.keys()
	var order: Array[Vector2i] = []
	while not pool.is_empty():
		var total := 0.0
		for s in pool:
			total += room_weights[s]
		var roll := rng.randf() * total
		var idx := 0
		for i in pool.size():
			roll -= room_weights[pool[i]]
			if roll <= 0.0:
				idx = i
				break
		order.append(room_sizes[pool[idx]])
		pool.remove_at(idx)
	return order

# Seeded Fisher-Yates shuffle.
func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
