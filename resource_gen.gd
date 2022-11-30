extends Node

var noise = OpenSimplexNoise
var map_size = Vector2(33, 33)
var env_chance # % that an item will be placed
# seed_chance
# ore_chance

onready var resource = preload("res://Pawns/Resource.tscn")
onready var item = preload("res://Pawns/Item.tscn")

onready var tiles : TileMap = get_parent().get_node("GroundTiles")
onready var entities : TileMap = get_parent().get_node("Entities")
onready var grid : TileMap = get_parent().get_node("Grid")

enum RESOURCE { TREE, ROCK, ORE }
enum ITEM { WOOD, STONE, GEM, TOOL }

func _ready():
	init_OpenSimplexNoise()
	generate_tiles() # generates tools afterwards
	generate_resources(10, 400)

func init_OpenSimplexNoise():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1.0
	noise.period = 12
	noise.persistence = 0.7

func generate_tiles():
	var tool_tiles = mode_settings.tool_spawns
	var TT = Array()
	var tool_clumping = 2
	for cellX in map_size.x:
		for cellY in map_size.y:
			if tiles.get_cell(cellX, cellY) != 0:
				#cellx+x_pos, cellY+y_pos
				tiles.set_cell(cellX, cellY, noise.get_noise_2d(cellX, cellY) + 2)
				if (tool_tiles > 0) and (((randi() % 100) + (randi() % 20)) < ((2 + mode_settings.tool_spawns) - tool_clumping)):
					tool_clumping+=1
					tiles.set_cell(cellX, cellY, 0)
					tool_tiles-=1
					TT.append(Vector2(cellX, cellY))
	for tile in TT:
		generate_tools(tile)

func generate_tools(tool_tile):
	var tool_item = item.instance()
	tool_item.item_type = ITEM.TOOL
	tool_item.position = (tool_tile * 24) + Vector2(12, 12)
	grid.add_child(tool_item)
	grid.update_cell(tool_tile, 2) # update to type OBJECT
	entities.place_tools(tool_item)

func generate_resources(chance, max_new_resources):
	env_chance = chance
	#var max_new_resources = max_new
	var count = 0
	for cellX in map_size.x:
		for cellY in map_size.y:
			if grid.get_cell(cellX, cellY) == -1: #and count < max_new_resources:
				match tiles.get_cell(cellX, cellY):
					1: # grass tiles generate trees
						if randi() % 100 < env_chance:
							var tree = resource.instance()
							tree.resource_type = RESOURCE.TREE
							tree.position = Vector2(cellX*24, cellY*24) + Vector2(12, 12)
							grid.add_child(tree)
							count+=1
							#entities.set_cell(cellX, cellY, 0)
					2: # stone tiles generate ores rarely
						if ((randi() % 100) + (randi() % 20)) < 1:
							var ore = resource.instance()
							ore.resource_type = RESOURCE.ORE
							ore.position = Vector2(cellX*24, cellY*24) + Vector2(12, 12)
							grid.add_child(ore)
							count+=1
							#entities.set_cell(cellX, cellY, 2)
						else: # stone tiles generate rocks
							if randi() % 100 < env_chance:
								var rock = resource.instance()
								rock.resource_type = RESOURCE.ROCK
								rock.position = Vector2(cellX*24, cellY*24) + Vector2(12, 12)
								grid.add_child(rock)
								count+=1
								#entities.set_cell(cellX, cellY, 1)
				if check_count(count, max_new_resources):
					return
	grid.update_grid()
	entities.update_grid()
	

func check_count(count, mnr):
	if count >= mnr:
		grid.update_grid()
		entities.update_grid()
	return count >= mnr

func generate_item(cell, drop): # called in GRID under ACTOR, drop is the item_id based on resource_id
	var new_item = item.instance()
	new_item.item_type = drop
	new_item.position = (cell * 24) + Vector2(12, 12)
	grid.add_child(new_item)
