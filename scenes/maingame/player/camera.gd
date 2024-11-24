class_name PlayerCamera
extends Camera2D

const BOSS_ZONE_BOTTOM_LIMIT = -692
const DEFAULT_BOTTOM_LIMIT = 690

func _on_player_boss_zone_trigger_player() -> void:	
	limit_bottom = BOSS_ZONE_BOTTOM_LIMIT

func setCameraLimits(limitBottom: int) -> void:
	limit_bottom = limitBottom
