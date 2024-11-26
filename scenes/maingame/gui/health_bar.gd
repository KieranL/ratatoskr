extends Control

@export var NAME: String :
	set(value):
		if name_label:
			name_label.text = value
@export var MAX_HEALTH := 100.0
@export var CURRENT_HEALTH := 100.0 :
	set(value):
		if health_bar:
			CURRENT_HEALTH = value
			update_health_bar(value)

@onready var name_label = $Name
@onready var health_bar = $HealthBar

var _health_bar_initial_size : int

func connect_to_entity(entity: Node2D):
	if entity is HornetNest:
		var nest = (entity as HornetNest)
		NAME = "HIVE"
		MAX_HEALTH = nest.MAX_HEALTH
		CURRENT_HEALTH = MAX_HEALTH
		(entity as HornetNest).healthChanged.connect(health_bar_changed)

func _ready() -> void:
	_health_bar_initial_size = health_bar.size.x

# Probably don't need this as well but having the setter on CURRENT_HEALTH allows for debugging and calling update_health_bar on its own wouldn't trigger it
func health_bar_changed(value):
	CURRENT_HEALTH = value

func update_health_bar(value):
	var percentage = CURRENT_HEALTH / MAX_HEALTH
	if percentage <= 100:
		health_bar.size.x = _health_bar_initial_size * percentage
