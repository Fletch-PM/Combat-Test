extends CharacterBody2D

const SPEED = 50

var player: CharacterBody2D = null
var current_target: Node2D = null
var chase_player: bool = false
var player_in_attack_range: bool = false
var health: int = 50
var taking_damage: bool = false
var is_dead: bool = false
var attack_damage = 20
var attacking = false
var can_attack = true  # Cooldown flag

signal add_point
signal shakeattack

@onready var game_camera: Camera2D = get_node("/root/Game/GameManager/Game Camera")
@onready var game_manager: Node = get_node("/root/Game/GameManager")
@onready var anim: AnimatedSprite2D = $"Enemy Sprite"
@onready var Attack_Hitbox = $"Enemy Attack"
@onready var attack_cooldown: Timer = $"Attack Timer"

func _ready():
	add_to_group("Enemy")

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if attacking:
		velocity = Vector2.ZERO
	else:
		if chase_player and player:
			var direction = (player.position - position).normalized()
			velocity = direction * SPEED

			if direction.x != 0:
				anim.flip_h = direction.x < 0

			anim.play("Move")
		else:
			velocity = Vector2.ZERO
			anim.play("Idle")

	move_and_slide()

# Attack Logic
func _on_enemy_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("damage"):
		player_in_attack_range = true
		current_target = body
		

		if not attacking and can_attack:
			_start_attack()

func _on_enemy_attack_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_range = false
		current_target = null
		

func _start_attack() -> void:
	if is_dead or attacking or not can_attack or current_target == null:
		return

	attacking = true
	can_attack = false
	anim.play("Attack")
	await anim.animation_finished

	if player_in_attack_range and current_target and current_target.is_inside_tree():
		current_target.damage(attack_damage)
		print("Enemy dealt", attack_damage, "damage to player.")

	attacking = false
	attack_cooldown.start()

func _on_attack_timer_timeout() -> void:
	can_attack = true

	if player_in_attack_range and current_target and not is_dead:
		_start_attack()

# Chase Player Logic
func _on_enemy_aggro_range_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		chase_player = true

func _on_enemy_aggro_range_body_exited(body: Node) -> void:
	if body == player:
		player = null
		chase_player = false

# Taking Damage Logic
func damage(attack_damage: int) -> void:
	if is_dead:
		return

	health -= attack_damage
	taking_damage = true
	anim.play("Damaged")
	emit_signal("shakeattack")
	game_camera.shakeattack()
	print("Enemy is taking", attack_damage, "damage! Current HP:", health)

	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("Death")
	attack_cooldown.stop()
	await anim.animation_finished

	emit_signal("add_point")
	game_manager.add_point()
	queue_free()
