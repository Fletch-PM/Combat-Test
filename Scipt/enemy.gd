extends CharacterBody2D

const SPEED = 50

var player: CharacterBody2D = null
var chase_player: bool = false
var player_in_attack_range: bool = false
var health: int = 50
var taking_damage: bool = false
var is_dead: bool = false
var attack_damage = 20
var attacking = false
var can_attack = true  # Cooldown flag

@onready var anim: AnimatedSprite2D = $"Enemy Sprite"
@onready var Attack_Hitbox = $"Enemy Attack"
@onready var attack_cooldown: Timer = $"Attack Timer"
@onready var Knockback = $"Knockback Timer"

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
#End of Chase Player Logic

#Attack Logic
func _on_enemy_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("damage"):
		player_in_attack_range = true
		if not attacking and can_attack:
			_start_attack(body)

func _on_enemy_attack_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_range = false

func _start_attack(target: Node2D) -> void:
	if is_dead or attacking or not can_attack:
		return

	attacking = true
	can_attack = false  # Block next attack until cooldown ends
	anim.play("Attack")
	await anim.animation_finished

	if target and target.is_inside_tree():
		target.damage(attack_damage)
		print("Enemy dealt", attack_damage, "damage to player.")

	attacking = false
	attack_cooldown.start()  # Start cooldown

#Attack Cooldown
func _on_attack_timer_timeout() -> void:
	can_attack = true

	if player_in_attack_range and player and not is_dead:
		_start_attack(player)
#End of Attack Logic

#Chase Player Logic
func _on_enemy_aggro_range_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		chase_player = true

func _on_enemy_aggro_range_body_exited(body: Node) -> void:
	if body == player:
		player = null
		chase_player = false

#Taking Damage Logic
func damage(attack_damage: int) -> void:
	if is_dead:
		return

	health -= attack_damage
	taking_damage = true
	anim.play("Damaged")
	print("Enemy is taking", attack_damage, "damage! Current HP:", health)

	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("Death")
	await anim.animation_finished
	queue_free()
#End of Taking Damage Logic
