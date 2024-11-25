extends Node2D

signal loadComplete()
signal winGame()
signal playerDied()

@onready var bossGate := $Gate/BossGate as BossGate
@onready var boss_music := $Player/BossTheme as AudioStreamPlayer2D
@onready var main_music := $Player/MainTheme as AudioStreamPlayer2D

@onready var _player := $Actors/Player
@onready var _camera := $PlayerCamera

@onready var _player_spawn := $PlayerSpawn

func _ready() -> void:
	_player.global_position = _player_spawn.global_position
	_camera.global_position = _player_spawn.global_position
	_camera.set_target(_player)
	loadComplete.emit()


func _on_boss_zone_trigger() -> void:
	main_music.stop()
	boss_music.play()
	bossGate.dropGate()

func _on_boss_win_game_trigger() -> void:
	winGame.emit()


func _on_player_died() -> void:
	playerDied.emit()
