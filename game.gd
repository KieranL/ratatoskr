class_name Game
extends Node

@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu
@onready var _game_over_menu := $InterfaceLayer/GameOverMenu as GameOverMenu
@onready var _acorn_transition := $InterfaceLayer/AcornScreenTransition as AcornScreenTransition
@onready var _win_menu := $InterfaceLayer/WinMenu as WinMenu
@onready var _level_node := $LevelNode

var is_game_over := false
var is_acorn_transition := false

enum LEVEL {
	LEVEL_1,
	LEVEL_2
}

@export var CURRENT_LEVEL := LEVEL.LEVEL_1 :
	set (value):
		var tree = get_tree()
		tree.paused = true
		for child in _level_node.get_children():
			_level_node.remove_child(child)
		if(value == LEVEL.LEVEL_1):
			var level:PackedScene = load("res://scenes/maingame/level/level.tscn")
			var new_level = level.instantiate()
			new_level.connect("playerDied", _on_player_died)
			_level_node.add_child(new_level)
		if(value == LEVEL.LEVEL_2):
			var level:PackedScene = load("res://scenes/maingame/level2/level2.tscn")
			var new_level = level.instantiate()
			new_level.connect("playerDied", _on_player_died)
			_level_node.add_child(new_level)
		start_acorn_transition()

func _ready() -> void:
	CURRENT_LEVEL = LEVEL.LEVEL_1
	start_acorn_transition()

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
	elif event.is_action_pressed("reload_scene"):
		reload_game()


func _on_player_died() -> void:
	is_game_over = true
	var tree := get_tree()
	tree.paused = true
	_game_over_menu.triggerMenu()


func _on_game_over_menu_game_restart() -> void:
	reload_game()
	
func _on_win_menu_game_restart() -> void:
	reload_game()

func reload_game() -> void:
	var tree := get_tree()
	tree.paused = false	
	is_game_over = false
	get_tree().reload_current_scene()

func start_acorn_transition() -> void:
	if is_acorn_transition == false:
		is_acorn_transition = true
		var tree := get_tree()
		tree.paused = true
		_acorn_transition.trigger()
		

func _on_acorn_screen_transition_finish() -> void:
	is_acorn_transition = false
	var tree := get_tree()
	tree.paused = false
		
		
		
