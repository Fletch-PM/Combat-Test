extends CharacterBody2D

const SPEED = 75
var hit_points: int = 100
var chase_player = false
var attack_player = false
var is_attacking = false
var can_attack: bool = true
var player: CharacterBody2D = null

@onready var anim: AnimatedSprite2D = $"Enemy Sprite"
@onready var hitbox: Area2D = $"Enemy Attack"
@onready var attack_timer: Timer = $"Attack Timer"

func _ready():
	anim.connect("animation_finished", self._on_animation_finished)
	attack_timer.connect("timeout", _on_attack_timer_timeout)

func _on_enemy_aggro_range_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		chase_player = true

func _on_enemy_aggro_range_body_exited(body: Node) -> void:
	if body == player:
		player = null
		chase_player = false

func _on_enemy_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		attack_player = true

func _on_enemy_attack_body_exited(body: Node2D) -> void:
	if body == player:
		attack_player = false

func _deal_damage():
	if player and player.has_method("take_damage"):
		player.take_damage(20)
		print("Enemy dealt damage to player!")
	can_attack = false
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_animation_finished():
	if anim.animation == "Attack":
		is_attacking = false

		# Deal damage *after* animation ends, if player still in hitbox
		if attack_player and can_attack and player and hitbox.get_overlapping_bodies().has(player):
			_deal_damage()

		if chase_player and player:
			anim.play("Move")

func _physics_process(_delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		return

	if attack_player and can_attack:
		is_attacking = true
		anim.play("Attack")
		velocity = Vector2.ZERO
		return

	if chase_player and player:
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED

		if direction.x != 0:
			var facing_left = direction.x < 0
			anim.flip_h = facing_left
			hitbox.position = Vector2(15, 0)
			var hitbox_offset = abs(hitbox.position.x)
			hitbox.position.x = -hitbox_offset if facing_left else hitbox_offset

		anim.play("Move")
	else:
		velocity = Vector2.ZERO
		anim.play("Idle")

	move_and_slide()
