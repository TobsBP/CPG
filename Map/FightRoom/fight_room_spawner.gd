extends Node

const INTEGRAL_SCENE = preload("res://enemies/integral/integral.tscn")
const SPAWN_INTERVAL := 3.0

var _timer := SPAWN_INTERVAL
var _spawn_points: Array[Node2D] = []

func _ready() -> void:
	for child in get_children():
		if child is Node2D:
			_spawn_points.append(child as Node2D)

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = SPAWN_INTERVAL
		_spawn()

func _spawn() -> void:
	if _spawn_points.is_empty():
		return
	var point: Node2D = _spawn_points[randi() % _spawn_points.size()]
	var integral := INTEGRAL_SCENE.instantiate()
	get_parent().add_child(integral)
	integral.global_position = point.global_position
