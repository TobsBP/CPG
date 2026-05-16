extends CharacterBody2D

signal hit_renzo

const SPEED := 700.0

var _dir := Vector2.RIGHT

func init(direction: Vector2) -> void:
	_dir = direction
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	velocity = _dir * SPEED
	move_and_slide()
	if position.x < -80 or position.x > 1280:
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	hit_renzo.emit()
	queue_free()
