extends CharacterBody2D

const SPEED = 200.0
const STRONG_DURATION := 5.0

var is_invincible := false
var _strong_timer := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	animated_sprite.play("down")
	animated_sprite.stop()

func _is_dialogue_open() -> bool:
	var dialog := get_tree().get_first_node_in_group("dialog_box")
	return dialog != null and dialog.visible

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M and event.ctrl_pressed and event.meta_pressed:
			is_invincible = true
			_strong_timer = STRONG_DURATION

func _physics_process(delta: float) -> void:
	if is_invincible:
		_strong_timer -= delta
		if _strong_timer <= 0.0:
			is_invincible = false

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
		if is_invincible:
			animated_sprite.play("strong_idle")
		else:
			animated_sprite.stop()
		return

	if is_invincible:
		if abs(direction.x) >= abs(direction.y):
			animated_sprite.play("strong_right" if direction.x > 0.0 else "strong_left")
		else:
			animated_sprite.play("strong_down" if direction.y > 0.0 else "strong_up")
		return

	var is_diagonal := direction.x != 0.0 and direction.y != 0.0

	if is_diagonal:
		if direction.y < 0.0:
			animated_sprite.play("up_right" if direction.x > 0.0 else "up_left")
		else:
			animated_sprite.play("down_right" if direction.x > 0.0 else "down_left")
	elif abs(direction.x) >= abs(direction.y):
		animated_sprite.play("rigth" if direction.x > 0.0 else "left")
	else:
		animated_sprite.play("down" if direction.y > 0.0 else "up")

func _on_area_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://Map/FightRoom/fight_room.tscn")
