class_name Axe
extends RigidBody2D

@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var sprite := $Sprite2D as Sprite2D
#var rotate_dir := 1.0
var direction := 0 as float
var attacked := false
var lastEnemyHit = null

func _process(delta: float) -> void:
	var parent := get_parent() as Node
	var parent_position := parent.global_position as Vector2
	self.global_position = Vector2(parent_position.x + (direction * 12), parent_position.y+15)

	if direction == 1:
		animation_player.play("swing")
	else:
		animation_player.play("swing_mirror")
	#if (rotation > PI / 2):
		#rotate_dir = -1.0
	#
	#rotation = rotation + (.1 * rotate_dir)
	

func destroy() -> void:

	lastEnemyHit = null

func _on_body_entered(body: Node) -> void:
	if lastEnemyHit != body:
		lastEnemyHit = body
		if body is Enemy:
			(body as Enemy).take_damage(100)
			attacked = true
		elif body is Hornet:
			(body as Hornet).take_damage(100)
			attacked = true
		elif body is HornetNest:
			(body as HornetNest).take_damage(100)
			attacked = true
		elif body is Boss:
			var x = body as Boss
			print(x.HEALTH)
			(body as Boss).take_damage(100)
			
		attacked = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
