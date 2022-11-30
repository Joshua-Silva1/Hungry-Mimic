extends Control

onready var turns_left = mode_settings.max_turns
var counter = 0

# RESOURCES
var spawn_resource_count = 5 # how many turns between each resource spawn
var clumping_value = 1 # higher values clump resources in top left of map (1-100)
var resource_spawn_amount = 10 # max new resources spawned

onready var resource_gen = get_parent().get_parent().get_parent().get_node("ResourceGen")
onready var t_track = get_parent().get_node("Time")
onready var s_track = get_parent().get_node("Score")

func _ready():
	update_turns(0)

func update_turns(value):
	turns_left -= value
	$TurnCount.text = "TURNS LEFT: " + str(turns_left)
	if turns_left <= 0:
		end_game()

# count sets of 5 for spawning new resources
func count_turn(value):
	counter+=value
	update_turns(value)
	if counter >= spawn_resource_count:
		counter = 0
		resource_gen.generate_resources(clumping_value, resource_spawn_amount)
		# SF Play sound effect for new spawns

func end_game():
	saved_scores.store_stats(s_track.get_score(), t_track.get_time())
	get_tree().change_scene("res://Endscreen.tscn")
	
