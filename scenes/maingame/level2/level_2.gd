extends Node2D

signal playerDied()

func _on_player_died() -> void:
	playerDied.emit()
