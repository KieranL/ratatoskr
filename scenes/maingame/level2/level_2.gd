class_name Level2
extends Node2D

signal playerDied()

@onready var boss_music := $Player/BossTheme as AudioStreamPlayer2D
@onready var main_music := $Player/MainTheme as AudioStreamPlayer2D

func _on_player_died() -> void:
	playerDied.emit()


func _on_boss_gate_static_body_trigger_boss_music() -> void:
	main_music.stop()
	boss_music.play()
