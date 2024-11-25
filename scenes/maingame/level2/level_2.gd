class_name Level2
extends Node2D

signal loadComplete()
signal playerDied()
signal playerWin()

@onready var boss_music := $Actors/Player/BossTheme as AudioStreamPlayer2D
@onready var main_music := $Actors/Player/MainTheme as AudioStreamPlayer2D

@onready var _player := $Actors/Player
@onready var _camera := $PlayerCamera

@onready var _player_spawn := $PlayerSpawn

func _ready() -> void:
	_player.global_position = _player_spawn.global_position
	_camera.global_position = _player_spawn.global_position
	_camera.set_target(_player)
	loadComplete.emit()

func _on_player_died() -> void:
	playerDied.emit()


func _on_boss_gate_static_body_trigger_boss_music() -> void:
	main_music.stop()
	boss_music.play()

func _on_spwaner_spawner_death() -> void:
	playerWin.emit()
