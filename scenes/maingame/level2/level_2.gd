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
	# only spawn player at spawn location if visible
	# hide spawn location node if you want to spawn player where player is in level
	# useful for debugging
	if _player_spawn.visible:
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


func _on_mini_boss_trigger_area_body_entered(body: Node2D) -> void:
	if body is Player:
		# TODO, make this a node with an area then set the limits to the bounds of that area
		const MINI_BOSS_CAMERA_LOWER_LIMIT = -2500
		(_camera as Camera2D).limit_bottom = MINI_BOSS_CAMERA_LOWER_LIMIT
		(_camera as Camera2D).limit_top = MINI_BOSS_CAMERA_LOWER_LIMIT - 400
