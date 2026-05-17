extends CharacterBody2D

const BASE_SPEED := 280.0
const STRONG_DURATION := 5.0

var speed_multiplier := 1.0
var is_invincible := false
var _strong_timer := 0.0

@onready var _anim := $AnimatedSprite2D as AnimatedSprite2D

func _ready() -> void:
	add_to_group("dodge_player")
	_anim.play("down")

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

	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = dir.normalized() * BASE_SPEED * speed_multiplier if dir != Vector2.ZERO else Vector2.ZERO
	move_and_slide()
	_update_animation(dir)

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		if is_invincible and _anim.animation != "strong_idle":
			_anim.play("strong_idle")
		return

	if is_invincible:
		var anim: String
		if abs(dir.x) >= abs(dir.y):
			anim = "strong_right" if dir.x > 0.0 else "strong_left"
		else:
			anim = "strong_down" if dir.y > 0.0 else "strong_up"
		if _anim.animation != anim:
			_anim.play(anim)
		return

	var moving_left: bool = dir.x < 0.0
	var moving_right: bool = dir.x > 0.0
	var moving_up: bool = dir.y < 0.0
	var moving_down: bool = dir.y > 0.0
	var anim: String = "down"
	if moving_up and moving_left:
		anim = "up_left"
	elif moving_up and moving_right:
		anim = "up_right"
	elif moving_down and moving_left:
		anim = "down_left"
	elif moving_down and moving_right:
		anim = "down_right"
	elif moving_up:
		anim = "up"
	elif moving_down:
		anim = "down"
	elif moving_left:
		anim = "left"
	elif moving_right:
		anim = "rigth"
	if _anim.animation != anim:
		_anim.play(anim)
