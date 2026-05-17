extends "res://teacher/teacher.gd"

var _visit_count := 0

func _start_dialogue() -> void:
	if _visit_count == 0:
		dialogue_lines = [" Olá, meu apelido é Soned,eu sou professor responsável pela disciplina de Álgebra Linear"]
	if _visit_count == 1:
		dialogue_lines = [" Gostaria de jogar meu mini game sobre coordenadas polares ?"]
	super._start_dialogue()

func _on_dialogue_finished() -> void:
	_talking = false
	_visit_count += 1
	if _visit_count == 2:
		await get_tree().create_timer(0.4).timeout
		get_tree().change_scene_to_file("res://minigames/FlapBird/flap_bird.tscn")
