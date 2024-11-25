extends Area2D

signal bossZoneLeaveTrigger()

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		bossZoneLeaveTrigger.emit()
