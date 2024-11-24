class_name MeleeAttack
extends Marker2D

const AXE_SCENE = preload("res://scenes/maingame/player/axe.tscn")

@onready var sound_slash := $Slash as AudioStreamPlayer2D
@onready var timer := $Cooldown as Timer

# This method is only called by Player.gd.
func attack(direction: float = 1.0) -> bool:
	if not timer.is_stopped():
		return false
	var nut := AXE_SCENE.instantiate() as Axe
	nut.global_position = Vector2(global_position.x + (direction * 50), global_position.y)
	nut.direction = direction

	nut.set_as_top_level(true)
	add_child(nut)
	sound_slash.play()
	timer.start()
	return true
