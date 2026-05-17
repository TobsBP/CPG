extends Node2D

const CORRECT_ANSWER := 2

func _on_confirm_pressed() -> void:
	var input: String = $UI/Bar/HBox/LineEdit.text.strip_edges()
	if input.is_valid_int() and int(input) == CORRECT_ANSWER:
		$UI/Bar/HBox/Feedback.text = "Correto!"
		$UI/Bar/HBox/Feedback.modulate = Color.GREEN
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
	else:
		$UI/Bar/HBox/Feedback.text = "Incorreto, tente novamente."
		$UI/Bar/HBox/Feedback.modulate = Color.RED

func _on_line_edit_text_submitted(text: String) -> void:
	_on_confirm_pressed()
