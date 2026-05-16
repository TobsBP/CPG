extends Area2D

enum Kind { HAZARD, SHIELD, SLOW, LIFE }

signal collected(node: Node, kind: int)
signal missed(node: Node)

const NUMBERS: Array[String] = ["1","2","3","4","5","6","7","8","9","10","12","15","20","25","30"]

var _kind := Kind.HAZARD
var _speed := 120.0
var speed_scale := 1.0

@onready var item_label: Label = $ItemLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(kind: int, speed: float) -> void:
	_kind = kind
	_speed = speed
	match _kind:
		Kind.HAZARD: item_label.text = NUMBERS[randi() % NUMBERS.size()]
		Kind.SHIELD:  item_label.text = "[S]"
		Kind.SLOW:    item_label.text = "[~]"
		Kind.LIFE:    item_label.text = "[+]"

func _process(delta: float) -> void:
	position.y += _speed * speed_scale * delta
	rotation += 1.2 * delta
	if position.y > 700:
		missed.emit(self)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collected.emit(self, _kind)
		queue_free()
