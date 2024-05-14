extends CharacterBody2D

# Скорость движения
@export var скорость = 100

# Границы локации (настройте эти значения)
@export var мин_x = -200
@export var макс_x = 200
@export var мин_y = -200
@export var макс_y = 200

# Текущее направление
var направление = Vector2.DOWN

# Переменные для анимации
const MAX_SPEED = 75
const ACCEL = 1500
const FRICTION = 600
const RUN_SPEED_MULTIPLIER = 2

var input = Vector2.ZERO
var is_running = false
var current_dir = "none"

# States for the goblin
enum {
	STANDING,
	WALKING
}
var state = STANDING

# Timers for state durations
var standing_timer = 0.0
var walking_timer = 0.0

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
# Update timers
	standing_timer += delta
	walking_timer += delta

# State machine
	match state:
		STANDING:
			if standing_timer >= 5.0:
				# Start walking in a random direction
				направление = Vector2(randi() % 2 - 1, randi() % 2 - 1).normalized()
				state = WALKING
				walking_timer = 0.0
		WALKING:
			if walking_timer >= 30.0:
				state = STANDING
				standing_timer = 0.0				
			else:
				# С небольшой вероятностью меняем направление
				if randi() % 100 < 10:  # 10% шанс изменить направление
					# Добавляем небольшое случайное отклонение к текущему направлению
					var random_offset = Vector2(randf() - 0.5, randf() - 0.5) * 0.5
					направление = (направление + random_offset).normalized()
			# Move the goblin
			input = направление
			slime_movement(delta)
			slime_anim(true)

func slime_movement(delta):
	# Устанавливаем множитель скорости (всегда 1, так как гоблин не бегает)
	var speed_multiplier = 1.0

	# Обновляем направление гоблина
	if input != Vector2.ZERO:
		current_dir = get_direction_name(input)

	# Обновляем скорость гоблина
	if input == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * (FRICTION * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * ACCEL * delta * speed_multiplier)
		velocity = velocity.limit_length(MAX_SPEED * speed_multiplier)

	# Перемещаем гоблина
	move_and_slide()

func slime_anim(movement):
	var anim_name = "Idle_" + current_dir
	if anim_name == "Idle_none":
		anim_name = "Idle_down"
	
	if movement:
		anim_name = "Bounce_" + current_dir
		if is_running:
			anim_name = "Run_" + current_dir  # Используем анимацию бега
	anim.play(anim_name)
	
	# Отзеркаливание анимации
	anim.flip_h = current_dir == "right"

func get_direction_name(input):
	if abs(input.x) > abs(input.y):
		return "right" if input.x > 0 else "left"
	else:
		return "down" if input.y > 0 else "up"

