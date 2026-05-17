extends Node2D

const BASE_SPAWN_INTERVAL := 2.5
const BASE_FALL_SPEED := 35.0

const WORD_POOL: Array[String] = [
	"do", "re", "mi", "fa", "sol", "la", "si",
	"nota", "clave", "acorde", "ritmo", "compasso", "melodia",
	"C4", "D5", "F3", "G7", "Am",
	"do#", "re#", "fa#", "sol#",
	"tom1", "tom2", "beat3",
	"abc", "123", "foo", "bar",
	"CODA", "FINE", "Da_Capo",
]

@export var word_scene: PackedScene = preload("res://minigames/regex/word_target.tscn")

var _lives := 3
var _score := 0
var _spawn_timer := 0.0
var _difficulty := 0.0
var _active_words: Array[Node] = []
var _current_regex := ""

@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var lives_label: Label = $UI/TopBar/LivesLabel
@onready var input_label: Label = $UI/RegexBar/InputLabel
@onready var feedback_label: Label = $UI/FeedbackLabel

func _ready() -> void:
	_update_ui()
	_update_input_display()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key := event as InputEventKey

	if key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
		_submit_regex()
		return

	if key.keycode == KEY_BACKSPACE:
		if _current_regex.length() > 0:
			_current_regex = _current_regex.left(-1)
			_update_input_display()
		return

	var unicode: int = key.unicode
	if unicode >= 32:
		_current_regex += char(unicode)
		_update_input_display()

func _update_input_display() -> void:
	input_label.text = "> " + _current_regex + "█"

func _process(delta: float) -> void:
	_score += int(delta * 3)
	_difficulty += delta * 0.01
	_spawn_timer += delta

	var interval := maxf(0.8, BASE_SPAWN_INTERVAL - _difficulty)
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_word()
	if(_score >= 100):
		_on_lobby_pressed()

	score_label.text = "Pontos: %d" % _score

func _spawn_word() -> void:
	var node := word_scene.instantiate()
	add_child(node)
	node.position.x = 1200.0
	node.position.y = randf_range(60.0, 580.0)
	var word := WORD_POOL[randi() % WORD_POOL.size()]
	var speed := BASE_FALL_SPEED + _difficulty * 8.0
	node.call("setup", word, speed)
	node.connect("escaped", _on_word_escaped)
	_active_words.append(node)

func _submit_regex() -> void:
	var trimmed := _current_regex.strip_edges()
	if trimmed.is_empty():
		return

	var rx := RegEx.new()
	if rx.compile(trimmed) != OK:
		_show_feedback("Regex invalido!", Color(1.0, 0.3, 0.3))
		_current_regex = ""
		_update_input_display()
		return

	var matched := 0
	var to_destroy: Array[Node] = []
	for word_node in _active_words:
		if not is_instance_valid(word_node):
			continue
		if rx.search(word_node.call("get_word")) != null:
			to_destroy.append(word_node)
			matched += 1

	for node in to_destroy:
		_active_words.erase(node)
		node.call("flash_destroy")

	_score += matched * 20

	if matched > 0:
		_show_feedback("%d destruida(s)! +%d pts" % [matched, matched * 20], Color(0.3, 1.0, 0.5))
	else:
		_show_feedback("Nenhuma correspondencia", Color(1.0, 0.6, 0.2))

	_current_regex = ""
	_update_input_display()

func _show_feedback(msg: String, color: Color) -> void:
	feedback_label.text = msg
	feedback_label.modulate = color
	get_tree().create_timer(1.5).timeout.connect(
		func(): if is_instance_valid(feedback_label): feedback_label.text = "")

func _on_word_escaped(node: Node) -> void:
	_active_words.erase(node)
	_lives -= 1
	_update_ui()
	if _lives <= 0:
		_game_over()

func _update_ui() -> void:
	score_label.text = "Pontos: %d" % _score
	lives_label.text = "Vidas: %s" % "# ".repeat(_lives).strip_edges()

func _game_over() -> void:
	GameManager.last_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://screens/game_over.tscn")
	set_process(false)
	set_process_input(false)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
