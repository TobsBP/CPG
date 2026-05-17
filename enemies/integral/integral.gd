extends CharacterBody2D

const SPEED = 50.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")
	animated_sprite.play("default")
	collision_layer = 4
	collision_mask = 16  # só detecta cérebro (layer 5)
	
func _physics_process(_delta: float) -> void:
	var brain := get_tree().get_first_node_in_group("life") as Node2D
	if brain == null:
		return

	var diff := brain.global_position - global_position
	var direction := diff.normalized()

	velocity = direction * SPEED
	move_and_slide()

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider != null and collider.is_in_group("life"):
			collider.take_damage()
			queue_free()
			return
