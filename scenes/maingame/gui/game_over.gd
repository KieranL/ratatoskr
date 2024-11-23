class_name GameOverMenu
extends Control

@onready var background_animation_player := $background_animation_player
@onready var text_animation_player := $color_background/CenterContainer/text_animation_player
@onready var color_background := $color_background
@onready var music := $"Game over music"

signal game_restart()

func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func triggerMenu():
	show();
	background_animation_player.play("background_fade")
	text_animation_player.play("game_over_text")
	music.play()
	

func _on_restart_button_pressed() -> void:
	game_restart.emit()
