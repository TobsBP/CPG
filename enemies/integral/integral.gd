extends CharacterBody2D

const SPEED = 50.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")
	animated_sprite.play("default")
	collision_layer = 4  # layer 3 — não interage com torres
	collision_mask = 1   # só colide com layer 1 cérebro
	
func _physics_process(_delta: float) -> void:
	var brain := get_tree().get_first_node_in_group("life") as Node2D
	if brain == null:
		return

	var diff := brain.global_position - global_position

	# Move only along dominant axis (4 directions)
	var direction: Vector2
	if abs(diff.x) >= abs(diff.y):
		direction = Vector2(sign(diff.x), 0)
	else:
		direction = Vector2(0, sign(diff.y))

	velocity = direction * SPEED
	move_and_slide()

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider != null and collider.is_in_group("life"):
			collider.take_damage()
			queue_free()
			return
