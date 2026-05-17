extends CharacterBody2D

@export var shot_direction := Vector2.RIGHT
@export var shot_cooldown := 1.5

const SHOT_SCENE = preload("res://player/shot/shot.tscn")

var _player_nearby := false
var _shoot_timer := 0.0

func _ready() -> void:
	$DetectionArea.body_entered.connect(_on_body_entered)
	$DetectionArea.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if not _player_nearby:
		return
	_shoot_timer -= delta
	if _shoot_timer <= 0.0:
		_shoot_timer = shot_cooldown
		_fire()

func _fire() -> void:
	var shot := SHOT_SCENE.instantiate()
	get_parent().add_child(shot)
	shot.global_position = global_position + shot_direction * 50
	shot.call("init", shot_direction)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		_shoot_timer = 0.0

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
