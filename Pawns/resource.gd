extends "res://Pawns/pawn.gd"

enum RESOURCE { TREE, ROCK, ORE }
export (RESOURCE) var resource_type = RESOURCE.TREE

onready var hp = 8 + 4 * resource_type

func take_damage(value):
	hp -= value
	#print("Player dealt %s damage!", value)
	return hp <= 0
