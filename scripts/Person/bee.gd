extends CharacterBody2D

# Скорость движения слайма
@export var speed = 50


# Границы локации (настройте эти значения)
@export var мин_x = -200
@export var макс_x = 200
@export var мин_y = -200
@export var макс_y = 200

# Текущее направление
var направление = Vector2.DOWN

var input = Vector2.ZERO

# Переменные для анимации
var current_dir = "none"

# Состояния слайма
enum {
	СТОИТ,
	ИДЕТ
}
var state = СТОИТ

# Таймеры для длительности состояний
var standing_timer = 0.0
var walking_timer = 0.0

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	# Обновляем таймеры
	standing_timer += delta
	walking_timer += delta

	# Машина состояний
	match state:
		СТОИТ:
			if standing_timer >= 5.0:
				# Начинаем идти в случайном направлении
				направление = Vector2(randi() % 2 - 1, randi() % 2 - 1).normalized()
				state = ИДЕТ
				walking_timer = 0.0
		ИДЕТ:
			if walking_timer >= 30.0:
				state = СТОИТ
				standing_timer = 0.0
			else:
				# С небольшой вероятностью меняем направление
				if randi() % 100 < 10:  # 10% шанс изменить направление
					# Добавляем небольшое случайное отклонение к текущему направлению
					var random_offset = Vector2(randf() - 0.5, randf() - 0.5) * 0.5
					направление = (направление + random_offset).normalized()
				# Двигаем слайма
			input = направление
			bee_movement(delta)
			bee_anim(true)

func bee_movement(delta):
	# Двигаем слайма с постоянной скоростью
	velocity = направление * speed
	# Обновляем направление слайма
	if input != Vector2.ZERO:
		current_dir = get_direction_name(input)
	move_and_slide()

func bee_anim(movement):
	var anim_name = "Idle_" + current_dir
	if state == ИДЕТ:
		anim_name = "Walk_" + current_dir
	else:
		anim_name = "Idle_" + current_dir
	
	if anim_name == "Idle_none":
		anim_name = "Idle_down"

	anim.play(anim_name)
	

func get_direction_name(input):
	if abs(input.x) > abs(input.y):
		return "right" if input.x > 0 else "left"
	else:
		return "down" if input.y > 0 else "up"
