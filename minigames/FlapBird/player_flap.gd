extends CharacterBody2D

@export var forward_speed := 250.0
@export var gravity := 900.0
@export var flap_force := -350.0

const SLOW_SCALE := 0.3
const SLOW_DURATION := 5.0

var game_started := false
var _is_slow_mo := false

@onready var _start_label: Label = $"../StartScreen/StartLabel"

func _ready():
	add_to_group("player")
	_blink_label()

func _blink_label() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_start_label, "modulate:a", 0.1, 0.5)
	tween.tween_property(_start_label, "modulate:a", 1.0, 0.5)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or not event.echo == false:
		return
	var key := event as InputEventKey
	if key.keycode == KEY_M and key.ctrl_pressed and (key.meta_pressed or key.alt_pressed):
		if game_started and not _is_slow_mo:
			_activate_slow_mo()

func _activate_slow_mo() -> void:
	_is_slow_mo = true
	Engine.time_scale = SLOW_SCALE
	get_tree().create_timer(SLOW_DURATION, true, false, true).timeout.connect(_end_slow_mo)

func _end_slow_mo() -> void:
	_is_slow_mo = false
	Engine.time_scale = 1.0

func _physics_process(delta):
	if not game_started:
		velocity = Vector2.ZERO
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_accept"):
			game_started = true
			_start_label.get_parent().queue_free()
		return

	velocity.x = forward_speed
	velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_accept"):
		velocity.y = flap_force

	move_and_slide()

func die():
	Engine.time_scale = 1.0
	set_physics_process(false)
	GameManager.last_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://screens/game_over.tscn")


func _on_area_infinito_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.completar_minigame("FLAP")
		get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
