extends Node2D

signal winGame()
signal playerDied()

@onready var bossGate := $Gate/BossGate as BossGate
@onready var boss_music := $BossTheme as AudioStreamPlayer2D
@onready var main_music := $MainTheme as AudioStreamPlayer2D

func _on_boss_zone_trigger() -> void:
	main_music.stop()
	boss_music.play()
	bossGate.dropGate()

func _on_boss_win_game_trigger() -> void:
	winGame.emit()


func _on_player_died() -> void:
	playerDied.emit()
