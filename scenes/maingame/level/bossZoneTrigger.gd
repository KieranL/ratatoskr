extends Area2D

signal bossZoneTrigger()

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		bossZoneTrigger.emit()
