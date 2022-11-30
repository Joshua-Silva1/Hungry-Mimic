extends AudioStreamPlayer

func _ready():
	volume_db = settings.music_volume
	if settings.music_enabled:
		play()
