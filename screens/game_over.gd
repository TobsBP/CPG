extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_try_again_button_pressed() -> void:
	if GameManager.last_scene_path != "":
		get_tree().change_scene_to_file(GameManager.last_scene_path)


func _on_lobby_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
