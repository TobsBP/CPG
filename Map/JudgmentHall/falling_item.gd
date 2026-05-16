extends Area2D

enum Type { HAZARD, SHIELD, SLOW, LIFE }

signal collected(node: Node, type: int)
signal missed(node: Node)

const NUMBERS := ["1","2","3","4","5","6","7","8","9","π","√2","3²","2³","∞","e"]

var _type := Type.HAZARD
var _speed := 120.0
var speed_scale := 1.0

@onready var item_label: Label = $ItemLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(type: int, speed: float) -> void:
	_type = type
	_speed = speed
	match _type:
		Type.HAZARD: item_label.text = NUMBERS[randi() % NUMBERS.size()]
		Type.SHIELD:  item_label.text = "🛡"
		Type.SLOW:    item_label.text = "🕶"
		Type.LIFE:    item_label.text = "❤"

func _process(delta: float) -> void:
	position.y += _speed * speed_scale * delta
	rotation += 1.2 * delta
	if position.y > 700:
		missed.emit(self)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collected.emit(self, _type)
		queue_free()
