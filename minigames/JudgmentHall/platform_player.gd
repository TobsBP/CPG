extends CharacterBody2D

signal shoot_laser(from_pos: Vector2, direction: Vector2)

const SPEED := 300.0
const JUMP_VELOCITY := -580.0
const GRAVITY := 1200.0
const SHOOT_COOLDOWN := 0.25
const STRONG_DURATION := 5.0

var _shoot_timer := 0.0
var _facing := Vector2.RIGHT
var is_invincible := false
var _strong_timer := 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")

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

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if is_on_floor() and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")):
		velocity.y = JUMP_VELOCITY

	var dir_x := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir_x * SPEED

	_shoot_timer -= delta
	if Input.is_key_pressed(KEY_E) and _shoot_timer <= 0.0:
		shoot_laser.emit(global_position, _facing)
		_shoot_timer = SHOOT_COOLDOWN

	_update_animation(dir_x)
	move_and_slide()

func _update_animation(dir_x: float) -> void:
	if dir_x > 0:
		_facing = Vector2.RIGHT
		anim.flip_h = false
		anim.play("strong_right" if is_invincible else "rigth")
	elif dir_x < 0:
		_facing = Vector2.LEFT
		anim.flip_h = false
		anim.play("strong_left" if is_invincible else "left")
	else:
		if is_invincible:
			if anim.animation != "strong_idle":
				anim.play("strong_idle")
		else:
			anim.stop()
