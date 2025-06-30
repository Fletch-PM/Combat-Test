extends CharacterBody2D

const SPEED = 100
var chase_player = false
var player: CharacterBody2D = null

@onready var anim = $"Enemy Sprite"
@onready var Player = $"."

func _physics_process(delta: float) -> void:
	if chase_player and player:
		var direction = (player.position - position).normalized()
		position += direction * SPEED * delta
		anim.play("Move")
	else:
		anim.play("Idle")

func _on_enemy_aggro_range_body_entered(other: CharacterBody2D) -> void:
	if other.is_in_group("Player"):
		player = other
		chase_player = true

func _on_enemy_aggro_range_body_exited(other: CharacterBody2D) -> void:
	if other == player:
		player = null
		chase_player = false
