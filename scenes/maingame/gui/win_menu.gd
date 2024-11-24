class_name WinMenu
extends Control

@onready var centerContainer := $ColorRect/CenterContainer
@onready var colorRect := $ColorRect

signal game_restart()

func _ready() -> void:
	hide()

func open() -> void:
	show()
	
	var tween = create_tween()
	tween.tween_property(centerContainer, "position", Vector2(0,0), .5)

func _on_button_pressed() -> void:
	game_restart.emit()

func _on_level_win_game() -> void:
	open()
