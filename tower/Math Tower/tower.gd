extends CharacterBody2D

const DETECTION_RANGE = 150.0
const FIRE_RATE = 2.0

@export var shot_scene: PackedScene = preload("res://tower/shot/shot.tscn")
@export var shot_direction := Vector2(-0.866025, 0.5)

var _fire_timer := 0.0
var _player_in_range := false

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	collision_layer = 1

func _process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	_player_in_range = global_position.distance_to(player.global_position) <= DETECTION_RANGE

	if not _player_in_range:
		return

	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire_timer = FIRE_RATE
		_shoot()

func _shoot() -> void:
	var shot := shot_scene.instantiate() as CharacterBody2D
	get_tree().current_scene.add_child(shot)
	var direction := shot_direction.normalized()
	shot.global_position = global_position + direction * 25.0
	shot.add_collision_exception_with(self)
	shot.launch(direction)
