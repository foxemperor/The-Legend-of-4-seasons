extends CharacterBody2D

# Movement speed
@export var speed = 100

# Location boundaries (adjust these values)
@export var min_x = -200
@export var max_x = 200
@export var min_y = -0
@export var max_y = 150

# Current direction
var direction = Vector2.DOWN

# Animation variables
const MAX_SPEED = 75
const ACCEL = 1500
const FRICTION = 600
const RUN_SPEED_MULTIPLIER = 2

var input = Vector2.ZERO
var is_running = false
var current_dir = "none"

# Enemy
var enemy = null

# States for the goblin
enum {
	STANDING,
	WALKING,
	CHASING
}
var state = STANDING

# Timers for state durations
var standing_timer = 0.0
var walking_timer = 0.0

@onready var anim = $AnimatedSprite2D
@onready var health = get_node("AnimatedSprite2D").get_parent()

@export var current_health = 1 #  Хп моба
var damage = 1 # Урон
var damage_applied = false

func _ready():
	add_to_group("mob")

func _physics_process(delta):
	# Обновляем таймеры
	standing_timer += delta
	walking_timer += delta
	if current_health <= 0:
		await get_tree().create_timer(0.5).timeout
		anim.play("Die_" + current_dir)
		if anim.frame == 3:
			queue_free()

	# Машина состояний
	match state:
		STANDING:
			if enemy != null:
				is_running = true
				state = CHASING
			# Если таймер стояния больше 5 секунд
			elif standing_timer >= 5.0:
				# Начинаем идти в случайном направлении
				direction = Vector2(randi() % 2 - 1, randi() % 2 - 1).normalized()
				is_running = false
				state = WALKING
				walking_timer = 0.0
		WALKING:
			if enemy != null:
				is_running = true
				state = CHASING
			# Если таймер ходьбы больше 30 секунд
			elif walking_timer >= 30.0:
				is_running = false
				state = STANDING
				standing_timer = 0.0
			else:
				# С небольшой вероятностью меняем направление
				if randi() % 100 < 10:  # 10% шанс изменить направление
					# Добавляем небольшое случайное отклонение к текущему направлению
					var random_offset = Vector2(randf() - 0.5, randf() - 0.5) * 0.5
					direction = (direction + random_offset).normalized()
			# Двигаем гоблина
			input = direction
			goblin_movement(delta)
			goblin_anim(true)
			
		CHASING:
			# Если враг обнаружен
			if enemy != null:
				# Двигаемся в сторону врага
				direction = (enemy.position - position).normalized()
				input = direction
				goblin_movement(delta)
				goblin_anim(true)
			else:
				# Возвращаемся в состояние стояния
				is_running = false
				state = STANDING
				standing_timer = 0.0

func goblin_movement(delta):
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

func goblin_anim(movement):
	var anim_name = "Idle_" + current_dir
	if anim_name == "Idle_none":
		anim_name = "Idle_down"
	
	if movement:
		anim_name = "Walk_" + current_dir
		if is_running:
			anim_name = "Hop_" + current_dir  # Используем анимацию бега
	anim.play(anim_name)
	
	# Отзеркаливание анимации
	anim.flip_h = current_dir == "right"

func get_direction_name(input):
	if abs(input.x) > abs(input.y):
		return "right" if input.x > 0 else "left"
	else:
		return "down" if input.y > 0 else "up"

func _on_detected_body_entered(body):
	# Запоминаем врага и переходим в состояние преследования
	#print("Body entered!")
	if body.is_in_group("player"):
		enemy = body
		state = CHASING

func _on_detected_body_exited(body):
	# Сбрасываем врага
	#print("Body exited!")
	enemy = null

func take_damage(damage: int):
	if damage_applied == false:
		damage_applied = true
		print("Моб получил урон:", damage)
		current_health -= damage
	#if current_health <= 0:
		#state = STANDING
		#anim.play("Die")  # Анимация смерти
		#return  # Выходим, чтобы не запускать анимацию урона
	#else:
		## Запускаем анимацию урона
		#var hurt_animation = "Hurt_" + current_dir
		#anim.play(hurt_animation)  # Анимация урона
		#emit_signal("damage_taken", damage, self)


#func _on_animation_finished():
	#if anim.animation == "Die_" + current_dir: 
		#queue_free()
	#elif anim.animation == "Hurt_" + current_dir: 
		## После анимации урона, переключитесь на анимацию ожидания
		#anim.play("Idle_" + current_dir)
