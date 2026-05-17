extends Node2D

signal reached_ground
signal word_typed(node)

var word := ""
var is_life_word := false
var _matched := 0
var _speed := 60.0

@onready var rich_label: RichTextLabel = $RichTextLabel

func setup(w: String, speed: float, life_word: bool = false) -> void:
	word = w
	_speed = speed
	is_life_word = life_word
	_matched = 0
	_refresh_label()

func set_matched(count: int) -> void:
	_matched = count
	_refresh_label()
	if _matched >= word.length():
		emit_signal("word_typed", self)

func reset_highlight() -> void:
	_matched = 0
	_refresh_label()

func _refresh_label() -> void:
	var done := word.left(_matched)
	var rest := word.substr(_matched)
	if is_life_word:
		rich_label.text = "[color=#FF6B6B][b]❤ %s[/b][/color][color=#FFB3B3]%s[/color]" % [done, rest]
	else:
		rich_label.text = "[color=#FFE040][b]%s[/b][/color][color=white]%s[/color]" % [done, rest]

func _process(delta: float) -> void:
	position.y += _speed * delta
	if position.y > 570:
		emit_signal("reached_ground")
		queue_free()
