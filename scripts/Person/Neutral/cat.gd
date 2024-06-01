extends CharacterBody2D

# Movement speed of the bee
@export var speed = 50

# Location boundaries (adjust these values)
@export var min_x = -200
@export var max_x = 200
@export var min_y = -200
@export var max_y = 200

# Current movement direction
var direction = Vector2.DOWN

# Movement vector
var input = Vector2.ZERO

# Variable for storing the current animation direction
var current_dir = "none"

# Enemy
var enemy = null

# States for the bee
enum {
	WALKING, # Walking
	CHASING # Chasing the enemy
}
var state = WALKING

# Reference to the AnimatedSprite2D node
@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	# State machine
	match state:
		WALKING:
			# If the enemy is detected
			if enemy != null:
				state = CHASING
			else:
				# With a small probability, change direction
				if randi() % 100 < 10:  # 10% chance to change direction
					# Add a small random offset to the current direction
					var random_offset = Vector2(randf() - 0.5, randf() - 0.5) * 0.5
					direction = (direction + random_offset).normalized()
			# Move the bee
			input = direction
			cat_movement(delta)
			cat_anim(true)
		CHASING:
			# If the enemy is detected
			if enemy != null:
				# Move towards the enemy
				direction = (enemy.position - position).normalized()
				cat_movement(delta)
				cat_anim(true)
			else:
				# Return to the standing state
				state = WALKING

func cat_movement(delta):
	# Move the bee with a constant speed
	velocity = direction * speed
	# Update the bee's direction
	if input != Vector2.ZERO:
		current_dir = get_direction_name(input)
	move_and_slide()

func cat_anim(movement):
	# Select the animation based on the state
	var anim_name = "Walk_" + current_dir
	# Play the selected animation
	anim.play(anim_name)

func get_direction_name(input):
	# Determine the direction of movement based on the input vector
	if abs(input.x) > abs(input.y):
		return "right" if input.x > 0 else "left"
	else:
		return "down" if input.y > 0 else "up"

func _on_detected_body_entered(body):
	# Remember the enemy and switch to the chasing state
	if body.is_in_group("non"):
		enemy = body
		state = CHASING

func _on_detected_body_exited(body):
	# Reset the enemy
	enemy = null
