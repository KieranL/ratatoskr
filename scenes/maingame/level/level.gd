extends Node2D

signal winGame()

@onready var bossGate := $Gate/BossGate as BossGate

func _on_boss_zone_trigger() -> void:
	bossGate.dropGate()

func _on_boss_win_game_trigger() -> void:
	print("win")
	winGame.emit()
