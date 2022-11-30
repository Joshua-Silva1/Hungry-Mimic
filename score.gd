extends Control

var score = 0

func _ready():
	update_score(0)

func update_score(value):
	if $STextTimer.time_left > 0:
		$STextTimer.stop()
		$STextTimer.start()
	else:
		$STextTimer.start()
		adjust_text(1.2, "7ed177")
	score += value
	$ScoreCount.text = "SCORE: " + str(score)

func adjust_text(scale, colour):
	$ScoreCount.set_scale(Vector2(scale, scale))
	$ScoreCount.set_modulate(colour)

func _on_STextTimer_timeout():
	adjust_text(1, "ffffff")

func get_score():
	return score
