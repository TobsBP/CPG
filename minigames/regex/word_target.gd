extends Node2D

signal escaped(node: Node)

var _word := ""
var _speed := 40.0

@onready var label: Label = $Label

func setup(word: String, speed: float) -> void:
	_word = word
	label.text = word

func get_word() -> String:
	return _word

func _process(delta: float) -> void:
	position.x -= _speed * delta
	if position.x < -100.0:
		escaped.emit(self)
		queue_free()

func flash_destroy() -> void:
	modulate = Color(0.3, 1.0, 0.4)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.1)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
