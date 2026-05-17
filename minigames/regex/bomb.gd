extends Node2D

signal exploded

func drop(target_y: float) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", target_y, 0.55).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(_explode)

func _explode() -> void:
	exploded.emit()
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(4.0, 4.0), 0.25)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
