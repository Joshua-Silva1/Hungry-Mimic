extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT }
enum RESOURCE { TREE, ROCK, ORE }
enum ITEM { WOOD, STONE, GEM, TOOL }

var resource_number = 3

onready var Grid = get_parent().get_node("Grid")

func _ready():
	update_grid()

func update_cell(cell, item):
	#item = ITEM[item]
	set_cellv(cell, 3+item)

func update_grid():
	# Set the entities on the grid to the right index based on resource/item type
	for child in Grid.get_children():
		if child.type == ACTOR and child.name != "Player":
			set_cellv(world_to_map(child.position), child.resource_type)
		if child.type == OBJECT and child.item_type != 3:
			set_cellv(world_to_map(child.position), resource_number + child.item_type)

# places the tool items on the map
func place_tools(tool_item):
	#var tool_type = lerp(5, 8, randf()) # randomly chooses between 3 tools # tools are on indexes 6-8
	#print(tool_type)
	var num = 5 + int(rand_range(1, 4))
	if num == 9:
		num = 6
	set_cellv(world_to_map(tool_item.position), num) 

func is_item_at_target(cell):
	var cell_id = get_cell(cell.x, cell.y)
	return (cell_id >= resource_number and cell_id < 2*resource_number) ## if the target cell has an item in it BUT NOT A TOOL

func get_item_score(cell):
	var item_id = get_cell(cell.x, cell.y)
	return pow((item_id - 1), 4)

func get_item_index(cell):
	return get_cell(cell.x, cell.y)
