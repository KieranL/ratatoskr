extends CharacterBody2D

@onready var sprite := $Sprite2D as Sprite2D

@export var ROAM_COOLDOWN_IN_MS := 3000

@export var HUNT_SPEED := 300.0
@export var ROAM_SPEED := 200.0
var current_speed = 0.0

enum State {
	ROAMING,
	HUNTING,
	WAITING
}

var _state := State.ROAMING

var last_roam_target_location := Vector2()
var target_location := Vector2()
var target = Node2D

var home = CircleShape2D

func _ready() -> void:
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
		
	var direction = global_position.direction_to(target_location)
	velocity = direction * 100
		
	if not is_zero_approx(velocity.x):
		if velocity.x > 0.5:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

	move_and_slide()

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
