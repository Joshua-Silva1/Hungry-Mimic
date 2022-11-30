extends Control

func _ready():
	# Setting the leaderboard
	$VBoxContainer/One/T1.text = str(saved_scores.times[0], "              ")
	$VBoxContainer/One/S1.text = str(saved_scores.scores[0])
	if saved_scores.times.size() > 1:
		$VBoxContainer/Two/T2.text = str(saved_scores.times[1], "              ")
		$VBoxContainer/Two/S2.text = str(saved_scores.scores[1])
	if saved_scores.times.size() > 2:
		$VBoxContainer/Three/T3.text = str(saved_scores.times[2], "              ")
		$VBoxContainer/Three/S3.text = str(saved_scores.scores[2])


func _on_Restart_pressed():
	get_tree().change_scene("res://world.tscn")


func _on_Quit_pressed():
	get_tree().quit()
