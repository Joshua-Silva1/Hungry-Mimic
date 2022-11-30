extends Control

func _ready():
	$MenuMusic.volume_db = settings.music_volume
	$MenuMusic.play(settings.music_playback_position)
	$VBoxContainer/music_level/m_vol.text = str(-25 * 2 + 100)
	$VBoxContainer/fx_level/fx_vol.text = str(-25 * 2 + 100)

func _on_BackButton_pressed():
	settings.music_playback_position = $MenuMusic.get_playback_position()
	get_tree().change_scene("res://menu.tscn")


func _on_m_slider_value_changed(value : float) -> void:
	settings.music_volume = value
	$VBoxContainer/music_level/m_vol.text = str(value * 2 + 100)
	if value <= -50:
		settings.music_enabled = false
	else:
		settings.music_enabled = true
	_menu_audio_changed()
	

func _on_fx_slider_value_changed(value : float) -> void:
	settings.fx_volume = value
	$VBoxContainer/fx_level/fx_vol.text = str(value * 2 + 100)
	if value <= -50:
		settings.fx_enabled = false
	else:
		settings.fx_enabled = true

func _menu_audio_changed():
	if settings.music_enabled:
		if $MenuMusic.playing:
			$MenuMusic.volume_db = settings.music_volume
		else:
			$MenuMusic.play()
			$MenuMusic.volume_db = settings.music_volume
	else:
		$MenuMusic.stop()
