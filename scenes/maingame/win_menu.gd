class_name WinMenu
extends Control

signal game_restart()

func _ready() -> void:
	hide()

func open() -> void:
	show()

func _on_button_pressed() -> void:
	game_restart.emit()
