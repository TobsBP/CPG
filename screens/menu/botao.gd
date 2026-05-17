extends Control
@onready var menu_sprite: AnimatedSprite2D = $CanvasLayer/CenterContainer/VBoxContainer/Control/DetectionArea/MenuSprite
@onready var label: Label = $CanvasLayer/CenterContainer/VBoxContainer/Control/DetectionArea/Label

func _ready():
	menu_sprite.play("padrao")

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print("botão clicado!")
		get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
	
# Quando o botão Play é clicado
func _on_play_button_pressed():
	print("botão clicado!")
	var err = get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
	print("erro: ", err)
# Quando o mouse entra na zona perto do sprite
func _on_detection_area_mouse_entered():
	menu_sprite.play("perto")
	label.label_settings.font_size = 75

func _on_detection_area_mouse_exited():
	menu_sprite.play("padrao")
	label.label_settings.font_size = 64
