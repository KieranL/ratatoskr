class_name MeleeAttack
extends Marker2D
## Represents a squirrel that spawns and shoots nuts.
## The Cooldown timer controls the cooldown duration between shots.

const NUT_VELOCITY = 850.0
const NUT_SCENE = preload("res://scenes/maingame/player/nut_projectile.tscn")

@onready var sound_spit := $Shoot as AudioStreamPlayer2D
@onready var timer := $Cooldown as Timer


# This method is only called by Player.gd.
func attack(direction: float = 1.0) -> bool:
	if not timer.is_stopped():
		return false
	var nut := NUT_SCENE.instantiate() as NutProjectile
	nut.global_position = global_position
	nut.linear_velocity = Vector2(direction * NUT_VELOCITY, 0.0)

	nut.set_as_top_level(true)
	add_child(nut)
	sound_spit.play()
	timer.start()
	return true
