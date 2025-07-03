extends CharacterBody2D

const SPEED = 100

var last_direction: Vector2 = Vector2.RIGHT
var attack_damage = 25
var attacking = false
var hit_cooldown = false
var health: int = 100
var taking_damage: bool = false
var is_dead: bool = false
var bodies_in_attack_area: Array = []

@onready var anim = $"Player Sprite"
@onready var Attack_Hitbox = $"Player Attack Hitbox"
@onready var attack_timer = $"Attack Timer"
@onready var hitbox_default_offset = Attack_Hitbox.position

# Movement starter
func _physics_process(_delta: float) -> void:
	if is_dead:
		return  # Prevent any movement or input if dead

	velocity = Vector2.ZERO

# Movement input
	if Input.is_action_pressed("Left"):
		velocity.x -= 1
	if Input.is_action_pressed("Right"):
		velocity.x += 1
	if Input.is_action_pressed("Up"):
		velocity.y -= 1
	if Input.is_action_pressed("Down"):
		velocity.y += 1

	velocity = velocity.normalized() * SPEED
	move_and_slide()

func _process(_delta):
	if is_dead:
		return 
#End of Movement Logic

# Flip sprite and attack hitbox direction
	if velocity.x < 0:
		anim.flip_h = true
		Attack_Hitbox.position = hitbox_default_offset + Vector2(-15, 0)
	elif velocity.x > 0:
		anim.flip_h = false
		Attack_Hitbox.position = hitbox_default_offset + Vector2(15, 0)

# Animation handling
	if not attacking:
		if velocity.length() > 0:
			last_direction = velocity.normalized()
			anim.play("Move")
		else:
			anim.play("Idle")

# Attack input
	if Input.is_action_just_pressed("Attack") and not attacking:
		_start_attack()

#Attack Logic
func _start_attack() -> void:
	attacking = true
	hit_cooldown = false
	anim.play("Attack")
	attack_timer.start()

	for body in bodies_in_attack_area:
		if body != null and body.is_in_group("Enemy") and body.has_method("damage") and not hit_cooldown:
			body.damage(attack_damage)
			hit_cooldown = true
			return

func _on_player_attack_hitbox_body_entered(body: Node2D) -> void:
	if not bodies_in_attack_area.has(body):
		bodies_in_attack_area.append(body)

func _on_player_attack_hitbox_body_exited(body: Node2D) -> void:
	if bodies_in_attack_area.has(body):
		bodies_in_attack_area.erase(body)

func _on_attack_timer_timeout() -> void:
	attacking = false
#End Of Attack Logic

#Taking Damage Logic
func damage(attack_damage: int) -> void:
	if is_dead:
		return

	health -= attack_damage
	taking_damage = true
	print("player is taking", attack_damage, "damage! Current HP:", health)

	if health <= 0:
		die()
	else:
		anim.play("Damaged")

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("Death")
	await anim.animation_finished
#End Taking Damage Logic
