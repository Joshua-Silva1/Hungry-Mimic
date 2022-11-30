extends Sprite

#FRAME = DIFFERENT ITEM SPRITES
var end_destination = Vector2()

func fire_toward_player(): # end_destination
	set_process(false)
	$Tween.interpolate_property(self, "global_position", get_global_position(), end_destination, 0.05, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	#print("ITEM COLLECTED!")
	# SF Collect Sound Effect
	queue_free()

func _on_Timer_timeout():
	queue_free()
