class_name Axe
extends RigidBody2D


@onready var animation_player := $AnimationPlayer as AnimationPlayer
var rotate_dir := 1.0
var direction := 0 as float
var attacked := false

func _process(delta: float) -> void:
	var parent := get_parent() as Node
	var parent_position := parent.global_position as Vector2
	self.global_position = Vector2(parent_position.x + (direction * 30), parent_position.y)
	
	if (rotation > PI / 2):
		rotate_dir = -1.0
	
	rotation = rotation + (.1 * rotate_dir)
	

func destroy() -> void:
	animation_player.play(&"destroy")


func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		(body as Enemy).take_damage(100)
		attacked = true
