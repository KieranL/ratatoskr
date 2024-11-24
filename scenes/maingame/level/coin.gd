class_name Coin
extends Area2D
## Collectible that disappears when the player touches it.


@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	animation_player.play(&"picked")
<<<<<<< HEAD
	(body as Player).acorn_collected()
	(body as Player).coin_collected.emit()
=======
	if (body is Player):
		(body as Player).coin_collected.emit()
>>>>>>> Add basic hornet ai
