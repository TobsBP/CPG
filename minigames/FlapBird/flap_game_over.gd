extends CanvasLayer

func _ready() -> void:
	hide()
	add_to_group("flap_game_over")

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
