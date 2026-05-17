extends CharacterBody2D

@export var forward_speed := 250.0
@export var gravity := 900.0
@export var flap_force := -350.0

var game_started := false  # 🔥 controle de início

func _ready():
	add_to_group("player")


func _physics_process(delta):

	# ⛔ trava o jogo até apertar tecla
	if not game_started:
		velocity = Vector2.ZERO  # impede movimento
		if Input.is_action_just_pressed("ui_up"):
			game_started = true
		return

	# movimento automático para frente
	velocity.x = forward_speed

	# gravidade
	velocity.y += gravity * delta

	# flap (pulo)
	if Input.is_action_just_pressed("ui_up"):
		velocity.y = flap_force

	move_and_slide()


func die():
	set_physics_process(false)
	GameManager.last_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://screens/game_over.tscn")


func _on_area_infinito_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://Map/StudyRoom/study_room.tscn")
