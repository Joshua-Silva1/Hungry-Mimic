extends "res://Pawns/pawn.gd"

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT }

var damage = 1
var pickup_range = 1
var picking_up = false

onready var turn_counter = get_parent().get_parent().get_node("Interface/Parent/Turns")
onready var Grid = get_parent()

# Spawning dust
onready var dust_spawn = get_node("DustSpawn")
onready var dust_particles = preload("res://DustParticles.tscn")

# Sounds
onready var jump_sound = preload("res://Pawns/Sounds/moveSF_1.wav")
onready var hit_sound = preload("res://Pawns/Sounds/Hit_Sound(wood).wav")
onready var pull_items_sound = preload("res://Pawns/Sounds/pull_items_sound.wav") # Pull items in for pickup sound



func _ready():
	update_look_direction(Vector2(1, 0))

func _process(delta):
	var input_dir = get_input_direction()
	if not input_dir:
		return
	update_look_direction(input_dir)
	
	var target_pos = Grid.request_move(self, input_dir, damage)
	if target_pos and !picking_up:
		move_to(target_pos)
	else:
		bump(target_pos)

func _unhandled_key_input(event):
	# check if picking up
	
	if event.is_action_pressed("pickup") and is_processing() and !picking_up:
		picking_up = true
		set_process(false)
		$Sprite.frame = 4
		pickup()

func get_input_direction():
	return Vector2(
			int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
			int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func update_look_direction(dir):
	#$Sprite.rotation = dir.angle()
	
	### CHANGE FACING OF SPRITE
	# FACE RIGHT
	if dir == Vector2(1,0): 
		$Sprite.frame = 0
		return
	# FACE LEFT
	if dir == Vector2(-1,0):
		$Sprite.frame = 1
		return
	# FACE DOWN
	if dir == Vector2(0,1) or dir == Vector2(1,1) or dir == Vector2(-1,1):
		$Sprite.frame = 2
		return
	# FACE UP
	if dir == Vector2(0,-1) or dir == Vector2(1,-1) or dir == Vector2(-1,-1):
		$Sprite.frame = 3
		return

func move_to(target_pos):
	set_process(false)
	## START WALK ANIMATION
	$AnimationPlayer.play("walk")
	
	
	# Animate the sprite moving
	$Tween.interpolate_property(self, "position", position, target_pos, $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	# Sound
	soundFX(1, jump_sound, 0)
	
	# Stop function only after animation finishes
	yield($AnimationPlayer, "animation_finished")
	create_dust()
	turn_counter.count_turn(1)
	set_process(true)
	

func bump(target):
	set_process(false)
	$AnimationPlayer.play("bump")
	
	#soundFX(0.5, jump_sound, 0) # bump sound if player hits edges

	soundFX(1, hit_sound, 10)
	yield($AnimationPlayer, "animation_finished")
	
	turn_counter.count_turn(1)
	set_process(true)

func pickup():
	Grid.nodes_in_radius(position, pickup_range)
	turn_counter.count_turn(1)
	
	# Animation
	$AnimationPlayer.play("pickup")
	
	soundFX(1, pull_items_sound, 10)
	
	yield($AnimationPlayer, "animation_finished")
	$Sprite.frame = 2
	set_process(true)
	picking_up = false
	#SF Sound for collecting (dynamic with picked up items? or score pitch shift?)

func soundFX(pitch, sound, vol_boost):
	if settings.fx_enabled:
		if $AudioStreamPlayer.get_stream() != sound:
			$AudioStreamPlayer.set_stream(sound)
		$AudioStreamPlayer.volume_db = settings.fx_volume + vol_boost
		$AudioStreamPlayer.pitch_scale = pitch
		$AudioStreamPlayer.play()

func create_dust():
	var dust_instance = dust_particles.instance()
	dust_instance.set_as_toplevel(true) # won't inherit transform from player
	dust_instance.global_position = dust_spawn.global_position
	add_child(dust_instance)
