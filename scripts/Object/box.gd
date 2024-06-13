extends CharacterBody2D

# Скорость движения коробки
@export var move_speed = 20

# Сила толчка
@export var push_force = 50

# Переменная для хранения тела игрока, который толкает коробку
var pushing_body: CharacterBody2D = null

func _physics_process(delta):
	# Двигаем коробку, если есть толчок
	if pushing_body != null:
		var push_direction = (global_position - pushing_body.global_position).normalized()
		velocity = push_direction * move_speed
		move_and_slide()

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		pushing_body = body

func _on_area_body_exited(body):
	if body == pushing_body:
		pushing_body = null
