extends CharacterBody2D

const MAX_HP = 100
const DAMAGE_PER_HIT = 10

var hp := MAX_HP

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("life")
	animated_sprite.play("default")
	collision_layer = 16  # layer 5 — detectado só pela integral
	collision_mask = 0

func take_damage() -> void:
	hp -= DAMAGE_PER_HIT
	animated_sprite.play("damage")

	if hp <= 0:
		# TODO: game over
		return

	await get_tree().create_timer(0.3).timeout
	if is_inside_tree():
		animated_sprite.play("default")
