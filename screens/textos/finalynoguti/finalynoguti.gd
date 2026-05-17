extends Node2D
@onready var label: Label = $Label

func _ready():
	iniciar_cutscene()

func iniciar_cutscene() -> void:
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", Color.WHITE)
	
	await _digitar("Parabens!!!...\nVc conseguiu aprender a digitar rapido...\n+1 Aura de Professor")
	await get_tree().create_timer(2.0).timeout
	
	print("Trocando de cena...")
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")

func _digitar(t: String) -> void:
	label.text = ""
	for c in t:
		label.text += c
		await get_tree().create_timer(0.05).timeout
