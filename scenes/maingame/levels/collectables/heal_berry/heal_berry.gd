class_name HealBerry
extends Area2D
## Collectible that disappears when the player touches it.


@onready var animation_player := $AnimationPlayer as AnimationPlayer
var collected = false

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	animation_player.play(&"picked")
	(body as Player).healberry_collected(50)
	collected = true
