extends CharacterBody2D

const BASE_SPEED := 280.0

var speed_multiplier := 1.0

func _ready() -> void:
	add_to_group("dodge_player")

func _physics_process(_delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = dir.normalized() * BASE_SPEED * speed_multiplier if dir != Vector2.ZERO else Vector2.ZERO
	move_and_slide()
