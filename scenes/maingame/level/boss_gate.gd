class_name BossGate
extends StaticBody2D

func _ready() -> void:
	hide()
	collision_layer = 1

func dropGate() -> void:
	show()
	collision_layer = 9
