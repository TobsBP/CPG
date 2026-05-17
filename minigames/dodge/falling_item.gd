extends Area2D

enum Type { HAZARD, HELMET, SPEED, LIFE, GLASSES, MONGO, NEO4J, SQL }

signal collected(node: Node, type: int)
signal missed(node: Node)

var _type := Type.HAZARD
var _speed := 300.0
var speed_scale := 1.0

@onready var item_label: Label = $ItemLabel
@onready var helmet_sprite: Sprite2D = $HelmetSprite
@onready var glasses_sprite: AnimatedSprite2D = $GlassesSprite
@onready var potion_sprite: Sprite2D = $PotionSprite
@onready var mongo_sprite: Sprite2D = $MongoSprite
@onready var neo4j_sprite: Sprite2D = $Neo4jSprite
@onready var sql_sprite: Sprite2D = $SqlSprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(type: int, speed: float) -> void:
	_type = type
	_speed = speed
	match _type:
		Type.HAZARD:
			item_label.text = "💣"
		Type.HELMET:
			item_label.hide()
			helmet_sprite.show()
		Type.SPEED:
			item_label.text = "⚡"
		Type.LIFE:
			item_label.hide()
			potion_sprite.show()
		Type.GLASSES:
			item_label.hide()
			glasses_sprite.show()
			glasses_sprite.play("default")
		Type.MONGO:
			item_label.hide()
			mongo_sprite.show()
		Type.NEO4J:
			item_label.hide()
			neo4j_sprite.show()
		Type.SQL:
			item_label.hide()
			sql_sprite.show()

func _process(delta: float) -> void:
	position.y += _speed * speed_scale * delta
	if position.y > 680:
		missed.emit(self)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("dodge_player"):
		collected.emit(self, _type)
		queue_free()
