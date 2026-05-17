extends CharacterBody2D

signal hit_renzo

const SPEED := 700.0

var _dir := Vector2.RIGHT

func init(direction: Vector2) -> void:
	_dir = direction
	rotation = direction.angle()

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	velocity = _dir * SPEED
	move_and_slide()
	if position.x < -80 or position.x > 1280 or position.y < -80 or position.y > 800:
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	hit_renzo.emit()
	queue_free()
