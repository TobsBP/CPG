extends CharacterBody2D

const SPEED = 200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")

func _is_dialogue_open() -> bool:
	var dialog := get_tree().get_first_node_in_group("dialog_box")
	return dialog != null and dialog.visible

func _physics_process(_delta: float) -> void:
	if _is_dialogue_open():
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation(Vector2.ZERO)
		return

	var direction := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_update_animation(direction)

func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		animated_sprite.stop()
		return

	animated_sprite.flip_h = false
	var is_diagonal := direction.x != 0.0 and direction.y != 0.0

	if is_diagonal:
		if direction.y < 0:
			if direction.x > 0:
				animated_sprite.play("up_right")
			else:
				animated_sprite.play("up_left")
		else:
			if direction.x > 0:
				animated_sprite.play("down_right")
			else:
				animated_sprite.play("down_left")
	elif abs(direction.x) >= abs(direction.y):
		if direction.x > 0:
			animated_sprite.flip_h = true
			animated_sprite.play("left")
		else:
			animated_sprite.play("left")
	else:
		if direction.y > 0:
			animated_sprite.play("down")
		else:
			animated_sprite.play("up")

func _on_area_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://Map/FightRoom/fight_room.tscn")
