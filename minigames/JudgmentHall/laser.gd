extends Area2D

signal hit_renzo

const SPEED := 700.0

var _dir := Vector2.RIGHT

func init(direction: Vector2) -> void:
	_dir = direction
	if direction.x < 0:
		$Sprite2D.flip_h = true

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	position += _dir * SPEED * delta
	if position.x < -80 or position.x > 1280:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("renzo_area"):
		hit_renzo.emit()
	queue_free()
