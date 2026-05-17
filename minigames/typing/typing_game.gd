extends Node2D

const WORDS: Array[String] = [
	"classe", "objeto", "heranca", "polimorfismo", "encapsulamento",
"template", "ponteiro", "referencia", "namespace", "biblioteca",
"compilador", "header", "struct", "vector", "string",
"iostream", "cout", "cin", "while", "for",
"if", "switch", "case", "funcao", "sobrecarga",
"construtor", "destrutor", "malloc", "new", "delete",
"memoria", "thread", "arquivo", "stream", "lambda",
"iterador", "algoritmo", "fila", "pilha", "lista",
"map", "set", "debug", "compilacao", "otimizacao"
]

const BASE_SPAWN_INTERVAL := 2.5
const BASE_SPEED := 60.0
const MAX_ACTIVE_WORDS := 6

@export var falling_word_scene: PackedScene = preload("res://minigames/typing/falling_word.tscn")

var _active_words: Array[Node] = []
var _target: Node = null
var _current_input := ""
var _score := 0
var _lives := 3
var _spawn_timer := 0.0
var _difficulty := 0.0

@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var lives_label: Label = $UI/TopBar/LivesLabel
@onready var input_label: Label = $UI/InputBox/InputLabel
@onready var word_container: Node2D = $WordContainer

func _ready() -> void:
	_update_ui()

func _process(delta: float) -> void:
	_difficulty += delta * 0.30
	_spawn_timer += delta
	var interval := maxf(1.0, BASE_SPAWN_INTERVAL - _difficulty)
	if _spawn_timer >= interval and _active_words.size() < MAX_ACTIVE_WORDS:
		_spawn_timer = 0.0
		_spawn_word()
	if(_score >= 150):
		_on_lobby_pressed()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	var key := event as InputEventKey
	if key.keycode == KEY_BACKSPACE:
		_reset_input()
		return

	var unicode: int = key.unicode
	if unicode == 0:
		return
	var c := char(unicode).to_lower()
	if c.unicode_at(0) < 97 or c.unicode_at(0) > 122:
		return

	_handle_char(c)

func _handle_char(c: String) -> void:
	if _target == null:
		# Procura uma palavra que comece com o que foi digitado até agora
		var tentative := _current_input + c
		for w in _active_words:
			if w.word.begins_with(tentative):
				_target = w
				_current_input = tentative
				_target.set_matched(_current_input.length())
				break
		if _target == null:
			# Nenhuma palavra começa com esse prefixo — ignora
			return
	else:
		var next_idx := _current_input.length()
		if next_idx < _target.word.length() and _target.word[next_idx] == c:
			_current_input += c
			_target.set_matched(_current_input.length())
		else:
			# Letra errada — reseta
			_reset_input()
			return

	_update_input_display()

func _reset_input() -> void:
	if _target != null:
		_target.reset_highlight()
		_target = null
	_current_input = ""
	_update_input_display()

func _on_word_typed(node: Node) -> void:
	_score += 10 + _target.word.length() * 2
	_active_words.erase(node)
	_target = null
	_current_input = ""
	_update_input_display()
	_update_ui()
	node.queue_free()

func _on_word_missed(node: Node) -> void:
	_active_words.erase(node)
	if _target == node:
		_target = null
		_current_input = ""
		_update_input_display()
	_lives -= 1
	_update_ui()
	if _lives <= 0:
		_game_over()

func _spawn_word() -> void:
	var w := WORDS[randi() % WORDS.size()]
	# Evita duplicatas
	for active in _active_words:
		if active.word == w:
			return
	var node := falling_word_scene.instantiate()
	word_container.add_child(node)
	node.position.x = randf_range(80.0, 1080.0)
	node.position.y = -20.0
	var speed := BASE_SPEED + _difficulty * 10.0
	node.setup(w, speed)
	node.word_typed.connect(_on_word_typed)
	node.reached_ground.connect(_on_word_missed.bind(node))
	_active_words.append(node)


	

func _update_ui() -> void:
	score_label.text = "Pontos: %d" % _score
	lives_label.text = "Vidas: %s" % "❤ ".repeat(_lives).strip_edges()

func _update_input_display() -> void:
	input_label.text = "> " + _current_input + "█"

func _game_over() -> void:
	GameManager.last_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://screens/game_over.tscn")
	set_process(false)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
