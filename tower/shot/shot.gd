extends CharacterBody2D

const SPEED = 300.0

var _direction := Vector2.RIGHT

func _ready() -> void:
	$AnimatedSprite2D.play("shot")

func launch(direction: Vector2) -> void:
	_direction = direction
	rotation = direction.angle()

func _physics_process(_delta: float) -> void:
	velocity = _direction * SPEED
	move_and_slide()

	if get_slide_collision_count() > 0:
		var collider = get_slide_collision(0).get_collider()
		if collider != null and collider.is_in_group("player"):
			# TODO: aplicar dano ao player aqui
			pass
		queue_free()
