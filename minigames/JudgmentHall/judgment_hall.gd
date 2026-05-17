extends Node2D

const BASE_SPAWN_INTERVAL := 1.2
const BASE_FALL_SPEED := 130.0
const SHIELD_DURATION := 3.0
const SLOW_DURATION := 5.0
const SLOW_SCALE := 0.35

const SPAWN_WEIGHTS := [70, 10, 10, 10]

# Posicoes no topo de cada plataforma onde Renzo pode teleportar
const RENZO_POSITIONS := [
	Vector2(200, 455),
	Vector2(576, 455),
	Vector2(950, 455),
	Vector2(340, 345),
	Vector2(810, 345),
	Vector2(576, 235),
]

@export var falling_item_scene: PackedScene = preload("res://minigames/JudgmentHall/falling_item.tscn")
@export var shot_scene: PackedScene = preload("res://player/shot/shot.tscn")

var _lives := 3
var _score := 0
var _spawn_timer := 0.0
var _difficulty := 0.0
var _shielded := false
var _shield_timer := 0.0
var _slowed := false
var _slow_timer := 0.0
var _active_items: Array[Node] = []
var _renzo_teleporting := false
var _renzo_hp := 5

@onready var player: Node2D = $Player
@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var lives_label: Label = $UI/TopBar/LivesLabel
@onready var buff_label: Label = $UI/BuffLabel
@onready var renzo: CharacterBody2D = $Renzo
@onready var renzo_anim: AnimatedSprite2D = $Renzo/AnimatedSprite2D
@onready var victory_panel: Panel = $UI/Victory
@onready var victory_score: Label = $UI/Victory/VictoryScore

func _ready() -> void:
	_update_ui()
	renzo_anim.play("default")
	player.connect("shoot_laser", _spawn_laser)

func _process(delta: float) -> void:
	_score += int(delta * 5)
	_difficulty += delta * 0.015
	_spawn_timer += delta

	var interval := maxf(0.4, BASE_SPAWN_INTERVAL - _difficulty)
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_item()

	if _shielded:
		_shield_timer -= delta
		if _shield_timer <= 0.0:
			_shielded = false

	if _slowed:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slowed = false
			_set_all_speed_scale(1.0)

	score_label.text = "Pontos: %d" % _score
	_update_buff_display()

func _spawn_laser(from_pos: Vector2, direction: Vector2) -> void:
	var laser := shot_scene.instantiate()
	add_child(laser)
	laser.global_position = from_pos + direction * 40
	laser.call("init", direction)
	laser.connect("hit_renzo", _renzo_take_hit)

func _renzo_take_hit() -> void:
	if _renzo_teleporting:
		return

	_renzo_hp -= 1
	_score += 50

	if _renzo_hp <= 0:
		_renzo_die()
		return

	_renzo_teleporting = true
	renzo_anim.play("teleport")
	await get_tree().create_timer(0.8).timeout
	if not is_instance_valid(renzo):
		_renzo_teleporting = false
		return

	var current := renzo.position
	var options := RENZO_POSITIONS.filter(func(p: Vector2) -> bool:
		return p.distance_to(current) > 10.0)
	renzo.position = options[randi() % options.size()]

	await get_tree().create_timer(0.8).timeout
	if not is_instance_valid(renzo):
		_renzo_teleporting = false
		return

	renzo_anim.play("default")
	_renzo_teleporting = false

func _renzo_die() -> void:
	_renzo_teleporting = true
	renzo_anim.play("death")

	await get_tree().create_timer(1.8).timeout
	
	if is_instance_valid(renzo):
		renzo.queue_free()

	victory_score.text = "Pontuacao Final: %d" % _score
	victory_panel.show()

	set_process(false)
	player.set_physics_process(false)

	# ⏳ espera 3 segundos
	await get_tree().create_timer(3.0).timeout

	# 🔄 volta para o lobby
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")

func _spawn_item() -> void:
	var kind := _weighted_random()
	var node := falling_item_scene.instantiate()
	add_child(node)
	node.position.x = randf_range(40.0, 1112.0)
	node.position.y = -30.0
	var speed := BASE_FALL_SPEED + _difficulty * 20.0
	node.call("setup", kind, speed)
	if _slowed:
		node.set("speed_scale", SLOW_SCALE)
	node.connect("collected", _on_item_collected)
	node.connect("missed", _on_item_missed)
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

func _on_item_collected(node: Node, kind: int) -> void:
	_active_items.erase(node)
	match kind:
		0:
			if _shielded:
				return
			_lives -= 1
			_update_ui()
			if _lives <= 0:
				_game_over()
		1:
			_shielded = true
			_shield_timer = SHIELD_DURATION
		2:
			_slowed = true
			_slow_timer = SLOW_DURATION
			_set_all_speed_scale(SLOW_SCALE)
		3:
			_lives = mini(_lives + 1, 5)
			_update_ui()

func _on_item_missed(node: Node) -> void:
	_active_items.erase(node)

func _set_all_speed_scale(scale: float) -> void:
	for item in _active_items:
		if is_instance_valid(item):
			item.set("speed_scale", scale)

func _update_ui() -> void:
	score_label.text = "Pontos: %d" % _score
	lives_label.text = "Vidas: %s" % "# ".repeat(_lives).strip_edges()

func _update_buff_display() -> void:
	var parts: Array[String] = []
	if _shielded:
		parts.append("[S] %.1fs" % _shield_timer)
	if _slowed:
		parts.append("[~] %.1fs" % _slow_timer)
	buff_label.text = " | ".join(parts)

func _game_over() -> void:
	GameManager.last_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://screens/game_over.tscn")

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
