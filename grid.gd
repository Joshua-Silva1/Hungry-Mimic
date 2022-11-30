extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT }
enum RESOURCE { TREE, ROCK, ORE }
enum ITEM { WOOD, STONE, GEM, TOOL}

onready var bullet = preload("res://Pawns/Item_Bullet.tscn")
onready var pickup_sound = preload("res://Pawns/Sounds/pickup_sound.wav") # getting a tool

onready var entities = get_parent().get_node("Entities")
onready var RG = get_parent().get_node("ResourceGen")
onready var player = get_node("Player")
onready var scorer = get_parent().get_node("Interface/Parent/Score")
onready var turns = get_parent().get_node("Interface/Parent/Turns")
onready var fx = get_parent().get_node("FX")

func _ready():
	update_grid()

# takes Vector2 coordinates and checks for nodes present there
func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return(node)

func request_move(pawn, dir, dmg):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + dir
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)
		OBJECT:
			var object_pawn = get_cell_pawn(cell_target)
			if object_pawn != null:
				if object_pawn.item_type == ITEM.TOOL:
					object_pawn.queue_free()
					update_cell(cell_target, -1)
					entities.update_cell(cell_target, -4) # empty target cell
					# Checking which tool
					var tool_id = entities.get_item_index(cell_target)
					match tool_id: # matching tool to powerup
						6:
							player.damage += 3
						7:
							player.pickup_range += 1
						8:
							turns.update_turns(-40)
					soundFX(1, pickup_sound, 20)
					
					
			return update_pawn_position(pawn, cell_start, cell_target)
		ACTOR:
			if get_cell_pawn(cell_target) != null:
				### HANDLING DAMAGE
				var pawn_node = get_node(get_cell_pawn(cell_target).name)
				if pawn_node.name != "Player" and pawn_node.take_damage(dmg): # if dmg destroys it
					#print("Resource destroyed!")
					var drop = pawn_node.resource_type
					RG.generate_item(cell_target, drop)
					pawn_node.queue_free()
					update_cell(cell_target, OBJECT)
					entities.update_cell(cell_target, drop)
				#print("Cell %s contains %s" % [cell_target, pawn_name])
			else:
				print("Null target")
	

func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	# check whether object/item is on player tile
	if entities.is_item_at_target(cell_start):
		set_cellv(cell_start, OBJECT)
	else:
		set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size / 2

func update_cell(cell, type):
	set_cellv(cell, type)

func update_grid():
	# Set the grid to the right index based on children type
	for child in get_children():
		if child.name != "Player":
			set_cellv(world_to_map(child.position), child.type)

func nodes_in_radius(centre_point, tile_radius):
	var centre_cell = world_to_map(centre_point)
	
	# Check (tile_radius * 8 + 1) tiles around player (including centre)
	var top_left = centre_cell - Vector2(tile_radius, tile_radius)
	
	# Creating an array of the tiles with objects
	var tile_array = Array()
	for i in range(1+2*tile_radius):
		for j in range(1+2*tile_radius):
			var current_cell = top_left + Vector2(i, j)
			if entities.is_item_at_target(current_cell):
				tile_array.append(current_cell)
	
	# Updating the tiles and deleting objects
	for item_cell in tile_array:
		var item_pawn = get_cell_pawn(item_cell)
		if item_pawn != null:
		#if item_pawn.name != "Player":
			var item_id = entities.get_item_index(item_cell) # store for later
			scorer.update_score(entities.get_item_score(item_cell))
			update_cell(item_cell, EMPTY) # sets the grid tile to empty
			entities.update_cell(item_cell, -4) # sets the entity tile to empty
			
			# Create new item_bullet to travel to player
			var b = bullet.instance()
			b.position = (item_pawn.position) / 24
			b.end_destination = player.position
			b.frame = item_id - 3
			item_pawn.add_child(b)
			b.fire_toward_player()
			yield(b, "tree_exited")
			if item_pawn.name != "Player":
				item_pawn.queue_free()
				#print("DELETED!")
		else:
			scorer.update_score(entities.get_item_score(item_cell))
			entities.update_cell(item_cell, -4) # sets the entity tile to empty

func get_pos_id(pos):
	get_cellv(world_to_map(pos))

## LAST MINUTE ADDITION FOR GLOBAL SOUNDS
func soundFX(pitch, sound, vol_boost):
	if settings.fx_enabled:
		if fx.get_stream() != sound:
			fx.set_stream(sound)
		fx.volume_db = settings.fx_volume + vol_boost
		fx.pitch_scale = pitch
		fx.play()
