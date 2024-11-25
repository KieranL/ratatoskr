class_name PlayerCamera
extends Camera2D

const BOSS_ZONE_BOTTOM_LIMIT = -692
const DEFAULT_BOTTOM_LIMIT = 690

var _target : Node2D

enum State {
	FOLLOWING,
	FIXED
}

func set_target(targetNode: Node2D):
	_target = targetNode

func _process(delta: float) -> void:
	if _target:
		position = _target.position

func _on_player_boss_zone_trigger_player() -> void:	
	limit_bottom = BOSS_ZONE_BOTTOM_LIMIT

func setCameraLimits(limitBottom: int) -> void:
	limit_bottom = limitBottom
