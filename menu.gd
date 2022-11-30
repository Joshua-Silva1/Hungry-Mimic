extends Control


func _ready():
	$MenuMusic.volume_db = settings.music_volume
	if settings.music_enabled:
		$MenuMusic.play(settings.music_playback_position)
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	get_tree().change_scene("res://world.tscn")

func _on_OptionsButton_pressed():
	settings.music_playback_position = $MenuMusic.get_playback_position()
	get_tree().change_scene("res://settings.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
