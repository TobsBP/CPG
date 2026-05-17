extends Node2D
@onready var label: Label = $Label

func _ready():
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", Color.WHITE)
	await _digitar("Agora vc aprendeu o que é um metaverso...\nTome Cuidado para não prender ninguem...\nAlguns não conseguem sair...")
	await get_tree().create_timer(2.0).timeout  # espera 2 segundos
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")

func _digitar(t: String):
	label.text = ""
	for c in t:
		label.text += c
		await get_tree().create_timer(0.05).timeout
