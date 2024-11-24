extends Node2D

signal winGameTrigger()

func _on_boss_win_game_trigger() -> void:
	winGameTrigger.emit()
