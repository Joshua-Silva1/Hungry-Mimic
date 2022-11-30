extends Control

var time = 0

func _ready():
	update_time()

func update_time():
	$TimeCount.text = "TIME: " + str(time)

func _on_Timer_timeout():
	time += 1
	update_time()

func get_time():
	return time
