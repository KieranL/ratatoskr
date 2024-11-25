class_name AcornScreenTransition
extends Node2D

signal finish_acorn_transition()

@onready var animation_player := $AnimationPlayer

var _is_playing = false;

func _ready() -> void:
	hide()

func trigger():
	show();
	animation_player.play("acron_transition_animation")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "acron_transition_animation":
		finish_acorn_transition.emit()
