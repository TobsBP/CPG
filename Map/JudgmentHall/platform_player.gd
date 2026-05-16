extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -580.0
const GRAVITY := 1200.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if is_on_floor() and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")):
		velocity.y = JUMP_VELOCITY

	var dir_x := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir_x * SPEED

	_update_animation(dir_x)
	move_and_slide()

func _update_animation(dir_x: float) -> void:
	if dir_x > 0:
		anim.flip_h = true
		anim.play("left")
	elif dir_x < 0:
		anim.flip_h = false
		anim.play("left")
	else:
		anim.flip_h = false
		anim.play("down")
