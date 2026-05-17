extends Node2D

const BASE_SPAWN_INTERVAL := 0.3
const BASE_FALL_SPEED := 300.0
const HELMET_DURATION := 3.0
const SPEED_DURATION := 4.0
const SLOW_DURATION := 5.0
const SLOW_SCALE := 0.35

# Weights: hazard, helmet, speed, life, glasses, qi
const SPAWN_WEIGHTS := [70, 5, 5, 5, 5, 10]

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

@onready var player: CharacterBody2D = $Player
@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var lives_label: Label = $UI/TopBar/LivesLabel
@onready var buff_label: Label = $UI/BuffLabel

func _ready() -> void:
	_update_ui()

func _process(delta: float) -> void:
	_score += int(delta * 5)
	_difficulty += delta * 0.015
	_spawn_timer += delta

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
		4:  # GLASSES — slow all falling items
			_slowed = true
			_slow_timer = SLOW_DURATION
			_set_all_speed_scale(SLOW_SCALE)
		5:  # QI
			_score += 50
			_update_ui()

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

func _game_over() -> void:
	$UI/GameOver.show()
	$UI/GameOver/FinalScore.text = "Pontuação Final: %d" % _score
	set_process(false)
	player.set_physics_process(false)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
