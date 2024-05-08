extends CharacterBody2D

@export var speed: int = 35
@onready var animation_player = $AnimationPlayer


const MAX_SPEED = 75
const ACCEL = 1500
const FRICTION = 600

const RUN_SPEED_MULTIPLIER = 2  # Множитель скорости бега

var input = Vector2.ZERO
var is_running = false
var current_dir = "none"
var idle_time = 0.0

func _process(delta):
	if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down"):
		idle_time += delta
	else:
		idle_time = 0.0


func _physics_process(delta):
	hero_movement(delta)


func get_input():
	input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input.normalized()

func hero_movement(delta):
	input = get_input()

	# Проверяем, зажата ли клавиша Shift
	is_running = Input.is_action_pressed("run")

	# Устанавливаем множитель скорости в зависимости от бега
	var speed_multiplier = 1.0
	if is_running == true:
		speed_multiplier = RUN_SPEED_MULTIPLIER

	# Обновляем направление персонажа
	if input != Vector2.ZERO:
		current_dir = get_direction_name(input)

	# Обновляем скорость персонажа
	if input == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * (FRICTION * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * ACCEL * delta * speed_multiplier)
		velocity = velocity.limit_length(MAX_SPEED * speed_multiplier)

	# Перемещаем персонажа
	move_and_slide()

	# Обновляем анимацию персонажа
	hero_anim(input != Vector2.ZERO)
	

func hero_anim(movement):
	var anim_name = "stay_" + current_dir
	if anim_name == "stay_none":
		anim_name = "stay_down"
	
	if movement:
		anim_name = "walk_" + current_dir
		if is_running:
			anim_name = "run_" + current_dir  # Используем анимацию бега
	
	if idle_time > 5.0:
		anim_name = ("wait_" + current_dir)
		if anim_name == "wait_none":
			anim_name = "wait_down"
	
	animation_player.play(anim_name)

# Вспомогательная функция для определения направления
func get_direction_name(input):
	if abs(input.x) > abs(input.y):
		return "right" if input.x > 0 else "left" 
	else:
		return "down" if input.y > 0 else "up"

func runningcheck(is_running):
	var check = false
	
	if is_running == true:
		check = true
	else:
		check = false
