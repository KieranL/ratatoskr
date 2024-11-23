class_name Game
extends Node

@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu
@onready var _game_over_menu := $InterfaceLayer/GameOverMenu as GameOverMenu

var is_game_over := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or \
				mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.set_input_as_handled()

	elif event.is_action_pressed(&"toggle_pause"):
		if not is_game_over:
			var tree := get_tree()
			tree.paused = not tree.paused
			if tree.paused:
				_pause_menu.open()
			else:
				_pause_menu.close()
			get_tree().root.set_input_as_handled()
	elif event.is_action_pressed("reload_scene") and not is_game_over:
		reload_game()


func _on_player_died() -> void:
	is_game_over = true
	var tree := get_tree()
	tree.paused = true
	_game_over_menu.triggerMenu()


func _on_game_over_menu_game_restart() -> void:
	reload_game()

func reload_game() -> void:
	var tree := get_tree()
	tree.paused = false	
	is_game_over = false
	get_tree().reload_current_scene()
