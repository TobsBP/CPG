extends Node2D

signal landed

func drop(target_y: float) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", target_y, 0.7).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees", 360.0, 0.7).set_trans(Tween.TRANS_LINEAR)
	tween.chain().tween_callback(_disappear)

func _disappear() -> void:
	landed.emit()
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(2.5, 2.5), 0.2)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
