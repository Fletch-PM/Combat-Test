extends CharacterBody2D

const SPEED = 100

# Variables
var hit_points: int = 100
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false

@onready var anim = $"Player Sprite"
@onready var Attack_Hitbox = $"Player Attack Hitbox"

func _physics_process(_delta: float) -> void:
	# Reset velocity
	velocity.x = 0
	velocity.y = 0

	# Handle attack input
	if Input.is_action_just_pressed("Attack") and not is_attacking:
		is_attacking = true
		anim.play("Attack")

	# If currently attacking, wait for animation to finish
	if is_attacking:
		if not anim.is_playing():
			is_attacking = false
		else:
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

	# Flip sprite and move hitbox left/right from center
	var flip_offset = 15  # how far you want the hitbox to shift from center

	if last_direction.x < 0:
		anim.flip_h = true
		Attack_Hitbox.position.x = -flip_offset
	elif last_direction.x > 0:
		anim.flip_h = false
		Attack_Hitbox.position.x = flip_offset


	# Move the character
	move_and_slide()
