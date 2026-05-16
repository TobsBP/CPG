extends CharacterBody2D

@export var forward_speed := 250.0
@export var gravity := 900.0
@export var flap_force := -350.0

func _ready():
	add_to_group("player")


func _physics_process(delta):

	# movimento automático para frente
	velocity.x = forward_speed

	# gravidade
	velocity.y += gravity * delta

	# flap (pulo)
	if Input.is_action_just_pressed("ui_up"):
		velocity.y = flap_force

	move_and_slide()


func die():
	get_tree().reload_current_scene()
