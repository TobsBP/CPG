extends CanvasLayer

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if key.keycode == KEY_ESCAPE and key.pressed and not key.echo:
		if visible:
			_resume()
		else:
			_pause()

func _pause() -> void:
	show()
	get_tree().paused = true

func _resume() -> void:
	hide()
	get_tree().paused = false

func _on_resume_pressed() -> void:
	_resume()

func _on_lobby_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Map/FightRoom/fight_room.tscn")
