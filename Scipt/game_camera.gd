extends Camera2D
#region Variables

var shake_strength := 0.0
var shake_decay := 20.0
var original_position := Vector2.ZERO
#endregion

#region Camera Shake Logic
func _ready() -> void:
	original_position = position

func _process(delta: float) -> void:
	if shake_strength > 0.01:
		var offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_strength
		position = original_position + offset
		shake_strength = max(shake_strength - shake_decay * delta, 0.0)
	else:
		position = original_position

func shake(strength: float = 8.0, decay: float = 20.0) -> void:
	shake_strength = strength
	shake_decay = decay
#endregion

#region Shake Strenght

# Connect this signal from Player or Enemy
func _on_player_shakedamage() -> void:
	shake(8.0)

func shakeattack():
	shake(3.0)
#endregion
