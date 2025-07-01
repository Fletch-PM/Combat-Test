extends CharacterBody2D

const SPEED = 100

var hit_points: int = 100
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var is_damaged: bool = false
var is_dead: bool = false

@onready var anim = $"Player Sprite"
@onready var Attack_Hitbox = $"Player Attack Hitbox"

func _ready():
	anim.connect("animation_finished", self._on_animation_finished)

func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Reset velocity
	velocity.x = 0
	velocity.y = 0

	# Handle attack input
	if Input.is_action_just_pressed("Attack") and not is_attacking and not is_damaged:
		is_attacking = true
		anim.play("Attack")

	# If currently attacking or damaged, wait for animation to finish
	if is_attacking or is_damaged:
		move_and_slide()
		return

	# Movement input
	if Input.is_action_pressed("Left"):
		velocity.x -= 1
	if Input.is_action_pressed("Right"):
		velocity.x += 1
	if Input.is_action_pressed("Up"):
		velocity.y -= 1
	if Input.is_action_pressed("Down"):
		velocity.y += 1

	# Normalize and apply speed
	velocity = velocity.normalized() * SPEED

	# Animation and direction tracking
	if velocity.length() > 0:
		last_direction = velocity.normalized()
		anim.play("Move")
	else:
		anim.play("Idle")

	# Flip sprite and move hitbox
	var flip_offset = 15
	if last_direction.x < 0:
		anim.flip_h = true
		Attack_Hitbox.position.x = -flip_offset
	elif last_direction.x > 0:
		anim.flip_h = false
		Attack_Hitbox.position.x = flip_offset

	move_and_slide()

# Called by enemies to deal damage
func take_damage(amount: int) -> void:
	if is_dead:
		return

	hit_points -= amount
	print("Player took", amount, "damage! Current HP:", hit_points)

	if hit_points <= 0:
		die()
	else:
		is_damaged = true
		anim.play("Damaged")

# Called when player dies
func die() -> void:
	is_dead = true
	print("Player died!")
	anim.play("Death")
	set_physics_process(false)

# Animation finished callback
func _on_animation_finished():
	if anim.animation == "Attack":
		is_attacking = false
	elif anim.animation == "Damaged":
		is_damaged = false
