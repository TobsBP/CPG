extends CanvasLayer

signal dialogue_finished

const CHAR_SPEED = 0.04

@onready var label: Label = $Panel/MarginContainer/VBoxContainer/Label
@onready var name_label: Label = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var continue_hint: Label = $Panel/MarginContainer/VBoxContainer/ContinueHint

var _lines: Array[String] = []
var _current_line := 0
var _typing := false
var _full_text := ""

func _ready() -> void:
	add_to_group("dialog_box")
	hide()

func start(speaker_name: String, lines: Array[String], speaker_world_pos: Vector2 = Vector2.ZERO) -> void:
	_lines = lines
	_current_line = 0
	name_label.text = speaker_name
	show()
	if speaker_world_pos != Vector2.ZERO:
		_position_above(speaker_world_pos)
	_show_line(_current_line)

func _position_above(world_pos: Vector2) -> void:
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * world_pos
	var panel: Control = $Panel
	# Salva tamanho antes de resetar anchors
	var saved_size := panel.size
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.size = saved_size
	# Centraliza horizontalmente, posiciona acima da cabeça do professor
	panel.position = screen_pos - Vector2(saved_size.x / 2.0, saved_size.y + 10.0)

func _show_line(index: int) -> void:
	_full_text = _lines[index]
	label.text = ""
	continue_hint.hide()
	_typing = true
	_type_text()

func _type_text() -> void:
	for i in _full_text.length():
		if not _typing:
			break
		label.text = _full_text.left(i + 1)
		await get_tree().create_timer(CHAR_SPEED).timeout
	label.text = _full_text
	_typing = false
	continue_hint.show()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if _typing:
			_typing = false
			label.text = _full_text
			continue_hint.show()
		else:
			_advance()

func _advance() -> void:
	_current_line += 1
	if _current_line < _lines.size():
		_show_line(_current_line)
	else:
		hide()
		emit_signal("dialogue_finished")
