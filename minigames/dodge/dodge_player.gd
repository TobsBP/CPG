extends CharacterBody2D

const BASE_SPEED := 280.0

var speed_multiplier := 1.0

@onready var _anim := $AnimatedSprite2D as AnimatedSprite2D

func _ready() -> void:
	add_to_group("dodge_player")
	_anim.play("down")

func _physics_process(_delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = dir.normalized() * BASE_SPEED * speed_multiplier if dir != Vector2.ZERO else Vector2.ZERO
	move_and_slide()
	_update_animation(dir)

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
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
