class_name Axe
extends RigidBody2D


@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _process(delta: float) -> void:
	rotation = rotation + 5


func destroy() -> void:
	animation_player.play(&"destroy")


func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		(body as Enemy).take_damage(100)
