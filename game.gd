class_name Game
extends Node

@onready var pause_menu: PauseMenu = $InterfaceLayer/PauseMenu
@onready var game_over_menu: GameOverMenu = $InterfaceLayer/GameOverMenu
@onready var acorn_transition: AcornScreenTransition = $InterfaceLayer/AcornScreenTransition
@onready var win_menu: WinMenu = $InterfaceLayer/WinMenu
@onready var level_node: Node2D = $LevelNode

var is_game_over: bool = false
var is_acorn_transition: bool = false

enum LEVEL { LEVEL_1, LEVEL_2 }
@export var current_level: LEVEL = LEVEL.LEVEL_2

func _ready():
	load_level(current_level)

func load_level(level: LEVEL):
	get_tree().paused = true
	
	# Remove any existing level
	for child in level_node.get_children():
		level_node.remove_child(child)
	
	# Load and add the new level
	match level:
		LEVEL.LEVEL_1:
			var level_scene: PackedScene = preload("res://scenes/maingame/level/level.tscn")
			var new_level = level_scene.instantiate()
			new_level.connect("playerDied", on_player_died)
			new_level.connect("loadComplete", on_level_loaded)
			level_node.add_child(new_level)
		LEVEL.LEVEL_2:
			var level_scene: PackedScene = preload("res://scenes/maingame/level2/level2.tscn")
			var new_level = level_scene.instantiate()
			new_level.connect("playerDied", on_player_died)
			new_level.connect("playerWin", on_player_win)
			new_level.connect("loadComplete", on_level_loaded)
			level_node.add_child(new_level)
	
func on_player_died():
	is_game_over = true
	get_tree().paused = true
	game_over_menu.triggerMenu()

func on_player_win():
	get_tree().paused = true
	win_menu.open()

func on_level_loaded():
	start_acorn_transition()

func on_game_over_menu_game_restart():
	reload_game()

func on_win_menu_game_restart():
	reload_game()

func reload_game():
	get_tree().paused = false
	is_game_over = false
	get_tree().reload_current_scene()

func start_acorn_transition():
	if !is_acorn_transition:
		is_acorn_transition = true
		get_tree().paused = true
		acorn_transition.trigger()

func on_acorn_screen_transition_finish():
	is_acorn_transition = false
	get_tree().paused = false

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
				pause_menu.open()
			else:
				pause_menu.close()
			get_tree().root.set_input_as_handled()
	elif event.is_action_pressed("reload_scene"):
		reload_game()
