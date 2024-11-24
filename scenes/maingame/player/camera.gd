extends Camera2D

const BOSS_ZONE_BOTTOM_LIMIT = -692
const DEFAULT_BOTTOM_LIMIT = 690

var _isBossZoneEntered := false

func _on_player_boss_zone_trigger_player() -> void:	
	if !_isBossZoneEntered:
		limit_bottom = BOSS_ZONE_BOTTOM_LIMIT
	else:
		limit_bottom = DEFAULT_BOTTOM_LIMIT
	
	_isBossZoneEntered = !_isBossZoneEntered
