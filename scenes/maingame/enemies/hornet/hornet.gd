class_name Hornet
extends CharacterBody2D

signal died()

@onready var sprite := $Sprite2D as Sprite2D

@export var ROAM_COOLDOWN_IN_MS := 3000

@export var HUNT_SPEED := 300.0
@export var ROAM_SPEED := 200.0
@export var CONTACT_DAMAGE := 30
@export var MAX_HEALTH := 150
@export var CURRENT_HEALTH : int
var current_speed = 0.0

enum State {
	ROAMING,
	HUNTING,
	WAITING,
	DEAD
}

var _state := State.ROAMING

var last_roam_target_location := Vector2()
var target_location := Vector2()
var target = Node2D

var home = CircleShape2D

var _hit_player := false

const FRAME_FLICKER_AMOUNT = 4
const FRAME_FLICKER_TIME = 400


func _ready() -> void:
	CURRENT_HEALTH = MAX_HEALTH
	current_speed = ROAM_SPEED
	_state = State.ROAMING
	target_location = global_position
	last_roam_target_location = target_location
	home = get_parent().get_node("RoamRadius/Area2D/roam_sphere")

func _physics_process(delta: float) -> void:
	if (_state == State.HUNTING):
		target_location = target.position
		
	if (_state == State.ROAMING):
		if (global_position.x - target_location.x <= 0.0):
			await pick_new_roam_target()
		
	if not _hit_player:
		var direction = global_position.direction_to(target_location)
		velocity = direction * 100
		
	if not is_zero_approx(velocity.x):
		if velocity.x > 0.5:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

	if _state != State.DEAD:
		var collision_occured = move_and_slide()
		if collision_occured:
			for i in get_slide_collision_count():
				var slide_collision = get_slide_collision(i)
				if slide_collision:
					var collider = get_slide_collision(i).get_collider()
					if (collider is Player):
						await hit_player(collider)


	move_and_slide()

func hit_player(collider) -> void:
	var player = collider #make typing more clear
	if not _hit_player:
		_hit_player = true
		player.hit(CONTACT_DAMAGE, self)
		velocity = Vector2.ZERO
		await get_tree().create_timer(1).timeout
		_hit_player = false

func destroy() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO
	died.emit()
	get_parent().remove_child(get_parent().get_node("RoamRadius"))
	queue_free()
	

func take_damage(damage) -> void:
	CURRENT_HEALTH -= damage
		
	trigger_invincible(FRAME_FLICKER_TIME)
	
	if CURRENT_HEALTH <= 0:
		destroy()

func hunt(huntTarget: Node2D) -> void:
	_state = State.HUNTING
	last_roam_target_location = target_location
	target = huntTarget
	current_speed = HUNT_SPEED

func roam() -> void:
	_state = State.ROAMING
	target_location = last_roam_target_location
	current_speed = ROAM_SPEED

func pick_new_roam_target():
	if _state != State.WAITING:
		_state = State.WAITING
		await get_tree().create_timer(5).timeout
		target_location.x = randf_range(home.global_position.x - home.shape.radius, home.global_position.x + home.shape.radius)
		_state = State.ROAMING

func _on_vision_sphere_body_entered(body: Node2D) -> void:
	if (body is Player):
		if _state != State.HUNTING:
			hunt(body)
	
func _on_vision_sphere_body_exited(body: Node2D) -> void:
	if (body is Player):
		if _state == State.HUNTING:
			roam()
			
func trigger_invincible(duration_in_ms) -> void:
	var duration_per_flicker = duration_in_ms / FRAME_FLICKER_AMOUNT / 2
	
	for i in FRAME_FLICKER_AMOUNT:
		sprite.visible = false
		await get_tree().create_timer(duration_per_flicker / 1000).timeout
		sprite.visible = true
		await get_tree().create_timer(duration_per_flicker / 1000).timeout
