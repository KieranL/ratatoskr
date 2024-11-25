class_name NutProjectile
extends RigidBody2D


@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var bounce_sound := $Bounce as AudioStreamPlayer2D

func destroy() -> void:
	animation_player.play(&"destroy")


func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		(body as Enemy).take_damage(50)
	elif body is Hornet:
		(body as Hornet).take_damage(50)
	elif body is HornetNest:
		(body as HornetNest).take_damage(50)
	elif body is Boss:
		(body as Boss).take_damage(50)
	else:
		bounce_sound.play()
