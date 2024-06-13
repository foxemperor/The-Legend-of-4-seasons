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
	STANDING, # Standing still
	WALKING, # Walking
	CHASING, # Chasing the enemy
	EXPLODING
}
var state = STANDING

# Timers for state durations
var standing_timer = 0.0
var walking_timer = 0.0
var explosion_delay_timer = 0.0

var damage_applied = false # Флаг для блокировки повторного урона

# Explosion delay before animation starts
@export var explosion_delay = 1.0

# Reference to the AnimatedSprite2D node
@onready var anim = $AnimatedSprite2D
@onready var health = get_node("AnimatedSprite2D").get_parent()

var current_health = 2 #  Хп моба
var damage = 1 # Урон

signal exploded(explosion_position)
signal damage_taken(damage_amount, mob_instance)

func _ready():
	add_to_group("mob")
	anim.animation_finished.connect(_on_explosion_animation_finished)
	anim.animation_finished.connect(_on_animation_finished)
	anim.frame_changed.connect(_on_frame_changed)

func _physics_process(delta):
	# Update timers
	standing_timer += delta
	walking_timer += delta
	explosion_delay_timer += delta

	# State machine
	match state:
		STANDING:
			# If the enemy is detected
			if enemy != null:
				state = CHASING
			# If the standing timer is greater than 5 seconds
			elif standing_timer >= 5.0:
				# Start walking in a random direction
				direction = Vector2(randi() % 2 - 1, randi() % 2 - 1).normalized()
				state = WALKING
				walking_timer = 0.0
		WALKING:
			# If the enemy is detected
			if enemy != null:
				state = CHASING
			# If the walking timer is greater than 30 seconds
			elif walking_timer >= 30.0:
				state = STANDING
				standing_timer = 0.0
			else:
				# With a small probability, change direction
				if randi() % 100 < 10:  # 10% chance to change direction
					# Add a small random offset to the current direction
					var random_offset = Vector2(randf() - 0.5, randf() - 0.5) * 0.5
					direction = (direction + random_offset).normalized()
			# Move the bee
			input = direction
			chom_movement(delta)
			chom_anim(true)
		CHASING:
			# If the enemy is detected
			if enemy != null:
				# Calculate distance to the enemy
				var distance_to_enemy = position.distance_to(enemy.position)
				# If close enough to the enemy
				if distance_to_enemy < 30:
					state = EXPLODING
					explosion_delay_timer = 0.0
				else:
					# Move towards the enemy
					direction = (enemy.position - position).normalized()
					chom_movement(delta)
					chom_anim(true)
			else:
				# Return to the standing state
				state = STANDING
				standing_timer = 0.0
		EXPLODING:
			# Stop moving
			velocity = Vector2.ZERO
			# Wait for the explosion delay
			if explosion_delay_timer >= explosion_delay:
				if current_dir == "none":
					current_dir = "down"
				# Play the explosion animation
				anim.play("Attack_" + current_dir)
				# Disable collision to prevent further interactions
				set_collision_mask_value(1, false)

func chom_movement(delta):
	# Move the bee with a constant speed
	velocity = direction * speed
	# Update the bee's direction
	if input != Vector2.ZERO:
		current_dir = get_direction_name(input)
	move_and_slide()

func chom_anim(movement):
	 # Select the animation based on the state
	if state == EXPLODING:
		return # Don't change animation during explosion
	var anim_name = "Idle_" + current_dir
	if state == WALKING:
		anim_name = "Walk_" + current_dir
	else:
		anim_name = "Idle_" + current_dir
	
	# If the direction is not defined, use the "Idle_down" animation
	if anim_name == "Idle_none":
		anim_name = "Idle_down"
		
	if current_dir == "none":
		current_dir = "down"

	# Play the selected animation
	anim.play(anim_name)
	
	# Mirror the animation if the chomper is moving right
	anim.flip_h = current_dir == "right"

func get_direction_name(input):
	# Determine the direction of movement based on the input vector
	if abs(input.x) > abs(input.y):
		return "right" if input.x > 0 else "left"
	else:
		return "down" if input.y > 0 else "up"

func _on_detected_body_entered(body):
	# Remember the enemy and switch to the chasing state
	if body.is_in_group("player"):
		enemy = body
		state = CHASING

func _on_detected_body_exited(body):
	# Reset the enemy
	 
	enemy = null
	
func _on_explosion_animation_finished():
	print("Before emitting 'exploded' signal")
	emit_signal("exploded", position)
	damage_applied = false # Сбрасываем флаг после взрыва
	queue_free()
	
func _on_explosion_keyframe():
	call_deferred("emit_signal", "exploded", global_position)

func _on_frame_changed():
	if anim.frame == 8 and state == EXPLODING: # Проверяем кадр и состояние
		emit_signal("exploded", global_position, self)
		

func take_damage(damage: int):
	print("Моб получил урон:", damage)
	current_health -= damage
	if current_health <= 0:
		state = STANDING
		anim.play("Die")  # Анимация смерти
		return  # Выходим, чтобы не запускать анимацию урона
	else:
		# Запускаем анимацию урона
		var hurt_animation = "Hurt_" + current_dir
		anim.play(hurt_animation)  # Анимация урона
		emit_signal("damage_taken", damage, self)


func _on_animation_finished():
	if anim.animation == "Die": 
		queue_free()
	elif anim.animation == "Hurt_" + current_dir: 
		# После анимации урона, переключитесь на анимацию ожидания
		anim.play("Idle_" + current_dir)
