extends CharacterBody2D

# Скорость движения слайма
@export var speed = 20

# Границы локации (настройте эти значения)
@export var min_x = -200
@export var max_x = 200
@export var min_y = -200
@export var max_y = 200

# Текущее направление движения
var direction = Vector2.DOWN

# Вектор движения
var input = Vector2.ZERO

# Переменная для хранения текущего направления анимации
var current_dir = "none"

# Враг
var enemy = null

# Состояния слайма
enum {
	STANDING, # Стоит на месте
	WALKING, # Идет
	CHASING # Преследует врага
}
var state = STANDING

# Таймеры для длительности состояний
var standing_timer = 0.0
var walking_timer = 0.0

# Ссылка на узел AnimatedSprite2D
@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	# Обновляем таймеры
	standing_timer += delta
	walking_timer += delta

	# Машина состояний
	match state:
		STANDING:
			# Если враг обнаружен
			if enemy != null:
				state = CHASING
			# Если таймер стояния больше 5 секунд
			elif standing_timer >= 5.0:
				# Начинаем идти в случайном направлении
				direction = Vector2(randi() % 2 - 1, randi() % 2 - 1).normalized()
				state = WALKING
				walking_timer = 0.0
		WALKING:
			# Если враг обнаружен
			if enemy != null:
				state = CHASING
			# Если таймер ходьбы больше 30 секунд
			elif walking_timer >= 30.0:
				state = STANDING
				standing_timer = 0.0
			else:
				# С небольшой вероятностью меняем направление
				if randi() % 100 < 10:  # 10% шанс изменить направление
					# Добавляем небольшое случайное отклонение к текущему направлению
					var random_offset = Vector2(randf() - 0.5, randf() - 0.5) * 0.5
					direction = (direction + random_offset).normalized()
			# Двигаем слайма
			input = direction
			slime_movement(delta)
			slime_anim(true)
		CHASING:
			# Если враг обнаружен
			if enemy != null:
				# Двигаемся в сторону врага
				direction = (enemy.position - position).normalized()
				slime_movement(delta)
				slime_anim(true)
			else:
				# Возвращаемся в состояние стояния
				state = STANDING
				standing_timer = 0.0

func slime_movement(delta):
	# Двигаем слайма с постоянной скоростью
	velocity = direction * speed
	# Обновляем направление слайма
	if input != Vector2.ZERO:
		current_dir = get_direction_name(input)
	move_and_slide()

func slime_anim(movement):
	# Выбираем анимацию в зависимости от состояния
	var anim_name = "Idle_" + current_dir
	if state == WALKING:
		anim_name = "Bounce_" + current_dir
	else:
		anim_name = "Idle_" + current_dir
	
	# Если направление не определено, используем анимацию "Idle_down"
	if anim_name == "Idle_none":
		anim_name = "Idle_down"

	# Проигрываем выбранную анимацию
	anim.play(anim_name)
	
	# Отзеркаливаем анимацию, если слайм движется вправо
	anim.flip_h = current_dir == "right"

func get_direction_name(input):
	# Определяем направление движения по вектору input
	if abs(input.x) > abs(input.y):
		return "right" if input.x > 0 else "left"
	else:
		return "down" if input.y > 0 else "up"

func _on_detected_body_entered(body):
	# Запоминаем врага и переходим в состояние преследования
	if body.is_in_group("player"):
		enemy = body
		state = CHASING

func _on_detected_body_exited(body):
	# Сбрасываем врага
	enemy = null
	
