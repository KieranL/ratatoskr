class_name HornetNest
extends CharacterBody2D

signal spawnerDeath()
signal healthChanged(current)

@export var MAX_SPAWNED_AT_ONE_TIME := 3
@export var SPAWN_COOLDOWN_IN_MS := 7500.0
@export var MAX_HEALTH := 750
@export var CURRENT_HEALTH: int
@export var HORNET_VISION_RADIUS := 200

@onready var hornets := $Hornets
@onready var sprite := $Sprite2D as Sprite2D
@onready var hit_sound := $Hit as AudioStreamPlayer2D
@onready var animation_player := $AnimationPlayer

var _on_cooldown = false
var _current_spawned = 0

const FRAME_FLICKER_AMOUNT = 4
const FRAME_FLICKER_TIME = 400

var hornet_scene = preload("res://scenes/maingame/entities/enemies/hornet/entity.tscn")

var _is_hit = false
var dead := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CURRENT_HEALTH = MAX_HEALTH
	
	for child in hornets.get_children():
		hornets.remove_child(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dead:
		return
	
	if _current_spawned < MAX_SPAWNED_AT_ONE_TIME:
		spawn_hornet()
	
	pass
	
func take_damage(damage) -> void:
	if _is_hit == false:
		_is_hit = true
		CURRENT_HEALTH -= damage
		healthChanged.emit(CURRENT_HEALTH)
		hit_sound.play()
		await trigger_invincible(FRAME_FLICKER_TIME)
	
		if CURRENT_HEALTH <= 0:
			destroy()
		_is_hit = false
		
func destroy() -> void:
	dead = true
	for entity in hornets.get_children():
		for child in entity.get_children():
			if child is Hornet:
				(child as Hornet).destroy()
	animation_player.play("death")

func spawn_hornet() -> void:
	if not _on_cooldown:
		_on_cooldown = true
		var entity = hornet_scene.instantiate()
		
		for child in entity.get_children():
			if child is Hornet:
				var hornet = child as Hornet
				hornet.connect("died", _hornet_died)
				hornet.VISION_SPHERE_RADIUS = HORNET_VISION_RADIUS
			child.global_position = global_position
		
		hornets.add_child(entity)
		
		await get_tree().create_timer(SPAWN_COOLDOWN_IN_MS / 1000).timeout
		_on_cooldown = false
		
		_current_spawned += 1
		
	
func _hornet_died() -> void:
	_current_spawned -= 1
	
func trigger_invincible(duration_in_ms) -> void:
	var duration_per_flicker = duration_in_ms / FRAME_FLICKER_AMOUNT / 2
	
	for i in FRAME_FLICKER_AMOUNT:
		sprite.visible = false
		await get_tree().create_timer(duration_per_flicker / 1000).timeout
		sprite.visible = true
		await get_tree().create_timer(duration_per_flicker / 1000).timeout


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		sprite.visible = false
		spawnerDeath.emit()
		queue_free()
