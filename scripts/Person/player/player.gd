class_name Player

extends CharacterBody2D

signal health_changed
signal death_finished
signal attack_finished

@onready var main_menu = preload("res://scenes/UI/main_menu.tscn")

@onready var hurt_box = $HurtBox as Area2D

@export var speed: int = 35
@onready var animation_player = $AnimationIdle as AnimationPlayer
@onready var sprite_idle = $SpriteIdle as Sprite2D
@onready var sprite_attack = $SpriteAttack as Sprite2D
@onready var game_over = $CanvasLayer/GameOver


@export var max_health = 2
@onready var current_health: int = max_health

@onready var explosion_radius = 50 # Пример
@onready var explosion_damage = 1 # Пример

@onready var attack_area = $AttackArea as Area2D
@onready var triangle_collision = $AttackArea/TriangleCollisionShape2D as CollisionShape2D
@onready var triangle_polygon = triangle_collision.shape as ConvexPolygonShape2D

const MAX_SPEED = 70
const ACCEL = 1500
const FRICTION = 600

const RUN_SPEED_MULTIPLIER = 2  # Множитель скорости бега

var input = Vector2.ZERO
var is_running = false
var is_death = false
var is_blocked = false
var is_attacking = false
var current_dir = "none"
var idle_time = 0.0
var in_group_player = false
var hearts_container

var mobs_in_attack_area = [] # Список мобов в зоне атаки

func _ready():	
	if is_in_group("player"):
		in_group_player = true
	else:
		add_to_group("player")
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	NavigationManager.level_loaded.connect(_on_level_loaded)
	hearts_container = get_node("../../CanvasLayer/HeartsContainer")
	set_physics_process(true) # Важно для `await`
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))
	_update_attack_area()  # Начальная инициализация треугольника

func _process(delta):
	if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down"):
		idle_time += delta
	else:
		idle_time = 0.0
	_update_attack_area()

func _physics_process(delta):
	hero_movement(delta)
	if is_death == false:
		for mob in get_tree().get_nodes_in_group("mob"):  # Проходим по всем мобам
			if mob.has_method("get_tree") and mob.anim is Node: # Проверка, есть ли у mob метод get_tree
				if mob.anim.frame == 8 and mob.state == mob.EXPLODING and not mob.damage_applied:  # Проверяем, взрывается ли моб
					var distance = global_position.distance_to(mob.global_position)
					if distance < explosion_radius:
						take_damage(1)
						mob.damage_applied = true
						break  # Выходим из цикла, если урон уже нанесен
	if is_attacking and animation_player.is_playing() and animation_player.get_current_animation_length() <= animation_player.get_current_animation_position():
		is_attacking = false
		sprite_attack.visible = false
		sprite_idle.visible = true

func _on_level_loaded(destination_tag):
	call_deferred("teleport_to_destination", destination_tag)

func teleport_to_destination(destination_tag):
	var destination_node = get_tree().get_root().find_node(destination_tag)
	if destination_node:
		global_position = destination_node.global_position
	else:
		push_error("Destination node not found: " + destination_tag)

func _unhandled_input(event):
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		$CanvasLayer/PauseMenu.visible = !$CanvasLayer/PauseMenu.visible
		get_tree().paused = $CanvasLayer/PauseMenu.visible

func get_input():
	input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input.normalized()

func _on_spawn(position: Vector2i, direction: String):
	global_position = position
	current_dir = direction
	animation_player.play("stay_" + current_dir)


func hero_movement(delta):
	input = get_input()	
	
	# Проверяем, клавиши
	is_running = Input.is_action_pressed("run")
	
	# Устанавливаем множитель скорости в зависимости от бега
	var speed_multiplier = 1.0
	
	if is_running == true:
		speed_multiplier = RUN_SPEED_MULTIPLIER
	
	# Проверяем блок перед обработкой движения
	if is_blocked == false:
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
	
	## Проверяем атаку
	if Input.is_action_pressed("attack"):
		is_attacking = true
		connect("attack_finished", Callable(self, "_on_animation_finished()"))
		disconnect("attack_finished", Callable(self, "_on_animation_finished()"))

		## Запускаем анимацию атаки 
		var attack_name = "attack_" + current_dir
		if attack_name == "attack_none":
			attack_name = "attack_down"

		# Останавливаем движение
		velocity = Vector2.ZERO
		input = Vector2.ZERO 

	else:
		is_attacking = false
		sprite_attack.visible = false
		sprite_idle.visible = true
	
	# Проверяем блок
	if Input.is_action_pressed("block"):
		is_blocked = true
		sprite_attack.visible = true
		sprite_idle.visible = false
		
		# Запускаем анимацию блока 
		var block_name = "block_" + current_dir
		if block_name == "block_none":
			block_name = "block_down"
		animation_player.play(block_name)

		# Останавливаем движение
		velocity = Vector2.ZERO
		input = Vector2.ZERO 
		
		# Продолжаем воспроизводить анимацию, пока кнопка зажата
		if animation_player.is_playing() and animation_player.get_current_animation_length() > 0.0: 
			animation_player.seek(0.0) # Возвращаем анимацию в начало

	else:
		is_blocked = false
		sprite_attack.visible = false
		sprite_idle.visible = true
	
	# Проверка для анимации смерти игрока
	if current_health == 0 and not is_death:
		
		is_death = true
		animation_player.play("die") # Проигрываем анимацию смерти
		
	# Перемещаем персонажа
	move_and_slide()
	
	# Обновляем анимацию персонажа
	hero_anim(input != Vector2.ZERO)
	

# Вспомогательная функция для определения направления
func get_direction_name(input):
	if abs(input.x) > abs(input.y):
		return "right" if input.x > 0 else "left" 
	else:
		return "down" if input.y > 0 else "up"

func hero_anim(movement):
	# Сначала проверяем, не должна ли воспроизводиться анимация смерти
	if is_death:
		game_over.visible = true
		animation_player.play("die")
		await get_tree().create_timer(animation_player.get_animation("die").get_length()).timeout 
		emit_signal("death_finished")
		return  # Выходим из функции, если смерть происходит
	
	if is_attacking:
		sprite_attack.visible = true
		sprite_idle.visible = false
		
		var attack_name = "attack_" + current_dir
		if attack_name == "attack_none":
			attack_name = "attack_down"
		animation_player.play(attack_name)
		await get_tree().create_timer(animation_player.get_animation(attack_name).get_length()).timeout 
		emit_signal("attack_finished")
		take_damage(0)
		return  # Выходим из функции
	
	var anim_name = "stay_" + current_dir
	if anim_name == "stay_none":
		anim_name = "stay_down"
	
	if movement:
		anim_name = "walk_" + current_dir
		if anim_name == "walk_none":
			anim_name = "walk_down"
		if is_running:
			anim_name = "run_" + current_dir  # Используем анимацию бега
	
	if idle_time > 5.0:
		anim_name = ("wait_" + current_dir)
		if anim_name == "wait_none":
			anim_name = "wait_down"	
	
	animation_player.play(anim_name)

func runningcheck(is_running):
	return is_running

func take_damage(damage: int):
	print("Player takes damage:", damage)
	if is_blocked == false:
		current_health -= damage  # Обновляем значение current_health
		hearts_container.update_hearts(current_health)
	
	print("Max hearts:", hearts_container.get_child_count())
	print("Current hearts:", hearts_container.get_full_hearts())
	if current_health <= 0 and not is_death:
		is_death = true
		connect("death_finished", Callable(self, "_on_death_finished"))

func _on_animation_finished():
	is_attacking = false
	sprite_attack.visible = false
	sprite_idle.visible = true

func _on_hurtbox_body_entered(body):
	if body.is_in_group("mob") and not is_blocked:
		take_damage(1)
		velocity = body.global_position.direction_to(global_position) * 10 # Отталкивание
	
func _on_death_finished(): # Обработчик сигнала
	await get_tree().change_scene_to_packed(main_menu)
	disconnect("death_finished", Callable(self, "_on_death_finished")) # Отключаем сигнал

func _update_attack_area():
	# Определяем точки треугольника
	var size_1 = 30  # Размер треугольника
	var size_2 = 30  # Размер треугольника
	var points = [
		Vector2(0, 0),
		Vector2(size_1, size_2),
		Vector2(-size_1, size_2)
	]

	# Поворачиваем КАЖДУЮ точку треугольника по направлению персонажа
	for i in range(points.size()):
		points[i] = points[i].rotated(deg_to_rad(get_direction_angle()))  # Поворачиваем каждую точку

	# Обновляем форму треугольника
	triangle_polygon.points = points

func get_direction_angle():
	# Возвращает угол направления в градусах
	if current_dir == "right":
		return 270
	elif current_dir == "left":
		return 90
	elif current_dir == "up":
		return 180
	elif current_dir == "down":
		return 0
	else:
		return 0

func _on_attack_area_body_entered(body):
	if body.is_in_group("mob") and not body.damage_applied:
		body.take_damage(1)
		body.damage_applied = true  # Отмечаем, что урон нанесен
		
		

