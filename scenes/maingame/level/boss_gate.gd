class_name BossGate
extends StaticBody2D

@onready var gateRect := $BossGateRect

var _isGateDropped = false

func _ready() -> void:
	hide()
	collision_layer = 1

func dropGate() -> void:
	show()
	collision_layer = 9
	
	if _isGateDropped:
		return
	
	_isGateDropped = true
	
	var tween = create_tween()
	tween.tween_property(gateRect, "position", Vector2(0,-224), .5)
	tween.tween_property(gateRect, "position", Vector2(0,-264), .1)
	tween.tween_property(gateRect, "position", Vector2(0,-224), .2)
