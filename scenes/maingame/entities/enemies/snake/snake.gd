class_name Enemy
extends CharacterBody2D

enum State {
	WALKING,
	DEAD,
	HURT
}

const WALK_SPEED = 22.0

var _state := State.WALKING

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var floor_detector_left := $FloorDetectorLeft as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var sprite := $Sprite2D as Sprite2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var collision_shape := $CollisionShape2D
@onready var damaged_sound := $Damaged as AudioStreamPlayer2D

@export var HEALTH := 100
@export var CONTACT_DAMAGE := 25

const FRAME_FLICKER_AMOUNT = 4
const FRAME_FLICKER_TIME = 400

func _physics_process(delta: float) -> void:
	if _state != State.HURT:
		if _state == State.WALKING and velocity.is_zero_approx():
			velocity.x = WALK_SPEED
		velocity.y += gravity * delta
		if not floor_detector_left.is_colliding():
			velocity.x = WALK_SPEED
		elif not floor_detector_right.is_colliding():
			velocity.x = -WALK_SPEED

	if is_on_wall():
		velocity.x = -velocity.x

	if _state != State.DEAD:
		var collision_occured = move_and_slide()
		if collision_occured:
			for i in get_slide_collision_count():
				var collider = get_slide_collision(i).get_collider()
				if (collider is Player):
					var player = collider #make typing more clear
					player.hit(CONTACT_DAMAGE, self)

	if velocity.x > 0.0:
		sprite.scale.x = 0.8
	elif velocity.x < 0.0:
		sprite.scale.x = -0.8

	if _state == State.HURT:
		return
	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func destroy() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO
	
func take_damage(damage) -> void:
	HEALTH -= damage
	damaged_sound.play()
	_state = State.HURT
	
	velocity = Vector2.ZERO
	if HEALTH <= 0:
		destroy()
	else:
		animation_player.play("damaged")


func get_new_animation() -> StringName:
	var animation_new: StringName
	if _state == State.WALKING:
		if velocity.x == 0:
			animation_new = &"idle"
		else:
			animation_new = &"walk"
	else:
		animation_new = &"destroy"
	return animation_new

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "destroy":
		queue_free()
	elif anim_name == "damaged":
		_state = State.WALKING
