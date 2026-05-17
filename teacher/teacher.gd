extends CharacterBody2D

@export var teacher_name: String = "Professor"
@export var dialogue_lines: Array[String] = [
	"Olá! Bem-vindo à aula.",
	"Pressione ENTER para continuar o diálogo.",
]
@export var interaction_radius: float = 60.0

var _dialog_box: Node = null
var _player_nearby := false
var _talking := false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	await get_tree().process_frame
	_dialog_box = get_tree().get_first_node_in_group("dialog_box")

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	_player_nearby = global_position.distance_to(player.global_position) <= interaction_radius

func _unhandled_input(event: InputEvent) -> void:
	if not _player_nearby or _talking:
		return
	if event.is_action_pressed("ui_accept"):
		_start_dialogue()

func _start_dialogue() -> void:
	if _dialog_box == null:
		_dialog_box = get_tree().get_first_node_in_group("dialog_box")
	if _dialog_box == null:
		return
	_talking = true
	_dialog_box.start(teacher_name, dialogue_lines, global_position)
	if not _dialog_box.dialogue_finished.is_connected(_on_dialogue_finished):
		_dialog_box.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_finished() -> void:
	_talking = false
	get_tree().change_scene_to_file("res://minigames/brownie/tela_do_chris.tscn")
