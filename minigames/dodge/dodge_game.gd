extends Node2D

const BASE_SPAWN_INTERVAL := 0.3
const BASE_FALL_SPEED := 300.0
const HELMET_DURATION := 3.0
const SPEED_DURATION := 4.0
const SLOW_DURATION := 5.0
const SLOW_SCALE := 0.35
const WIN_SCORE := 100
const CORRECT_POINTS := 30
const PROMPT_INTERVAL := 6.0

# Weights: hazard, helmet, speed, life, glasses, mongo, neo4j, sql
const SPAWN_WEIGHTS := [65, 5, 5, 5, 5, 5, 5, 5]

# Prompt index maps to DB type index (MONGO=5, NEO4J=6, SQL=7)
const PROMPT_LABELS := ["Banco Relacional", "Banco Orientado a Grafos", "Banco Orientado a Documentos"]
const PROMPT_TYPES  := [7, 6, 5]  # SQL, NEO4J, MONGO

@export var falling_item_scene: PackedScene = preload("res://minigames/dodge/falling_item.tscn")

var _lives := 3
var _score := 0
var _spawn_timer := 0.0
var _difficulty := 0.0
var _shielded := false
var _helmet_timer := 0.0
var _speed_timer := 0.0
var _slowed := false
var _slow_timer := 0.0
var _active_items: Array[Node] = []
var _prompt_idx := 0
var _prompt_timer := 0.0

@onready var player: CharacterBody2D = $Player
@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var lives_label: Label = $UI/TopBar/LivesLabel
@onready var buff_label: Label = $UI/BuffLabel
@onready var prompt_label: Label = $UI/TopBar/PromptLabel
@onready var victory_panel: Panel = $UI/Victory

func _ready() -> void:
	_prompt_idx = randi() % PROMPT_LABELS.size()
	_update_prompt()
	_update_ui()

func _process(delta: float) -> void:
	_difficulty += delta * 0.015
	_spawn_timer += delta
	_prompt_timer += delta

	if _prompt_timer >= PROMPT_INTERVAL:
		_prompt_timer = 0.0
		_next_prompt()
		
	var interval := maxf(0.4, BASE_SPAWN_INTERVAL - _difficulty)
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_item()

	if _shielded:
		_helmet_timer -= delta
		if _helmet_timer <= 0.0:
			_shielded = false

	if player.speed_multiplier > 1.0:
		_speed_timer -= delta
		if _speed_timer <= 0.0:
			player.speed_multiplier = 1.0

	if _slowed:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slowed = false
			_set_all_speed_scale(1.0)

	score_label.text = "Pontos: %d" % _score
	_update_buff_display()
	
func _next_prompt() -> void:
	_prompt_idx = (_prompt_idx + 1) % PROMPT_LABELS.size()
	_update_prompt()

func _update_prompt() -> void:
	prompt_label.text = "Colete: " + PROMPT_LABELS[_prompt_idx]

func _spawn_item() -> void:
	var type := _weighted_random()
	var node := falling_item_scene.instantiate()
	add_child(node)
	node.position.x = randf_range(40.0, 1112.0)
	node.position.y = -30.0
	var speed := BASE_FALL_SPEED + _difficulty * 20.0
	node.setup(type, speed)
	if _slowed:
		node.speed_scale = SLOW_SCALE
	node.collected.connect(_on_item_collected)
	node.missed.connect(_on_item_missed)
	_active_items.append(node)

func _weighted_random() -> int:
	var total := 0
	for w in SPAWN_WEIGHTS:
		total += w
	var roll := randi() % total
	var acc := 0
	for i in SPAWN_WEIGHTS.size():
		acc += SPAWN_WEIGHTS[i]
		if roll < acc:
			return i
	return 0

func _on_item_collected(node: Node, type: int) -> void:
	_active_items.erase(node)
	match type:
		0:  # HAZARD
			if _shielded:
				return
			_lives -= 1
			_update_ui()
			if _lives <= 0:
				_game_over()
		1:  # HELMET
			_shielded = true
			_helmet_timer = HELMET_DURATION
		2:  # SPEED
			player.speed_multiplier = 1.8
			_speed_timer = SPEED_DURATION
		3:  # LIFE
			_lives = mini(_lives + 1, 5)
			_update_ui()
		4:  # GLASSES
			_slowed = true
			_slow_timer = SLOW_DURATION
			_set_all_speed_scale(SLOW_SCALE)
		5, 6, 7:  # MONGO, NEO4J, SQL
			if type == PROMPT_TYPES[_prompt_idx]:
				_score += CORRECT_POINTS
				_update_ui()
				_prompt_timer = 0.0
				_next_prompt()
				if _score >= WIN_SCORE:
					_win()
			else:
				if _shielded:
					return
				_lives -= 1
				_update_ui()
				if _lives <= 0:
					_game_over()

func _on_item_missed(node: Node) -> void:
	_active_items.erase(node)

func _set_all_speed_scale(scale: float) -> void:
	for item in _active_items:
		if is_instance_valid(item):
			item.speed_scale = scale

func _update_ui() -> void:
	score_label.text = "Pontos: %d" % _score
	lives_label.text = "Vidas: %s" % "❤ ".repeat(_lives).strip_edges()

func _update_buff_display() -> void:
	var parts: Array[String] = []
	if _shielded:
		parts.append("🪖 %.1fs" % _helmet_timer)
	if player.speed_multiplier > 1.0:
		parts.append("⚡ %.1fs" % _speed_timer)
	if _slowed:
		parts.append("🕶 %.1fs" % _slow_timer)
	buff_label.text = " | ".join(parts)

func _win() -> void:
	victory_panel.show()
	set_process(false)
	player.set_physics_process(false)
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")

func _game_over() -> void:
	$UI/GameOver.show()
	$UI/GameOver/FinalScore.text = "Pontuação Final: %d" % _score
	set_process(false)
	player.set_physics_process(false)
	GameManager.last_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://screens/game_over.tscn")

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
