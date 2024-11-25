extends StaticBody2D

signal trigger_boss_music()
@onready var gateSprite := $BossGateSprite

var _isGateClosed = false

func _ready() -> void:
	hide()
	collision_layer = 1

func closeGate() -> void:
	show()
	collision_layer = 9
	_isGateClosed = true
	
	var tween = create_tween()
	tween.tween_property(gateSprite, "position", Vector2(-12,-150), .5)
	tween.tween_property(gateSprite, "position", Vector2(-12,-200), .1)
	tween.tween_property(gateSprite, "position", Vector2(-12,-150), .2)

func _on_mini_boss_trigger_area_body_entered(body: Node2D) -> void:	
	if !_isGateClosed:
		closeGate()
		trigger_boss_music.emit()
