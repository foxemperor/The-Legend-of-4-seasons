class_name Player

extends CharacterBody2D

signal health_changed

@onready var hurt_box = $HurtBox as Area2D

@export var speed: int = 35
@onready var animation_player = $AnimationIdle as AnimationPlayer
@onready var sprite_idle = $SpriteIdle as Sprite2D
@onready var sprite_attack = $SpriteAttack as Sprite2D

@export var max_health = 5
@onready var current_health: int = max_health

@onready var explosion_radius = 1000 # Пример
@onready var explosion_damage = 1 # Пример


const MAX_SPEED = 70
const ACCEL = 1500
const FRICTION = 600

const RUN_SPEED_MULTIPLIER = 2  # Множитель скорости бега

var input = Vector2.ZERO
var is_running = false
var current_dir = "none"
var idle_time = 0.0
var in_group_player = false

func _ready():
	if is_in_group("player"):
		in_group_player = true
	else:
		add_to_group("player")
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	NavigationManager.level_loaded.connect(_on_level_loaded)
	#get_tree().node_added.connect(_on_node_added) 
	health_changed.connect(update_hearts)

func _process(delta):
	if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down"):
		idle_time += delta
	else:
		idle_time = 0.0

func _physics_process(delta):
	hero_movement(delta)
	for mob in get_tree().get_nodes_in_group("mob"):  # Проходим по всем мобам
		if mob.anim.frame == 8 and mob.state == mob.EXPLODING:  # Проверяем, взрывается ли моб
			var distance = global_position.distance_to(mob.global_position)
			if distance < explosion_radius:
				take_damage(1)
				break  # Выходим из цикла, если урон уже нанесен

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
	
	if Input.is_action_just_pressed("attack"):
			attack()
	
	if Input.is_action_pressed("block"):
			block()
	
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

func runningcheck(is_running):
	return is_running

func attack() -> void:
	sprite_attack.visible = true
	sprite_idle.visible = false
	
	var attack_name = "attack_" + current_dir
	if attack_name == "attack_none":
		attack_name = "attack_down"
	
	animation_player.play(attack_name)
	
	var attack_stage = 0
	var attack_timer = 0.0
	
	# Комбинирование атаки по количеству нажатия кнопки атаки
	var animation_length = animation_player.get_current_animation_length()
	var seek_position = attack_stage * 0.5
	if seek_position >= animation_length:
		seek_position = animation_length - 0.01
	animation_player.seek(seek_position)
	
	attack_timer = 0.0
	attack_stage = (attack_stage + 1) % 3  # Циклическое переключение между этапами атаки

func block() -> void:
	if Input.is_action_pressed("block"):
		sprite_attack.visible = true
		sprite_idle.visible = false
		
		var block_name = "block_" + current_dir
		if block_name == "block_none":
			block_name = "block_down"
		
		animation_player.play(block_name)
		# Ниже переход к последнему кадру блока, чтобы можно было его удерживать
		animation_player.seek(animation_player.get_current_animation_length() - 0.01)
	else:
		sprite_attack.visible = false
		sprite_idle.visible = true
		animation_player.play("stay_" + current_dir)

func take_damage(damage):
	print("Player takes damage:", damage)
	var hearts_container = get_node("../../CanvasLayer/HeartsContainer") # Полный путь
	hearts_container.update_hearts(hearts_container.get_child_count() - damage)
	if hearts_container.get_child_count() <= 0:
		queue_free()
	
func _on_node_added(node):
	if node.is_in_group("mob"):
		node.exploded.connect(_on_mob_exploded)

func _on_mob_exploded(explosion_position):
	print("Mob exploded at:", explosion_position)
	var distance = global_position.distance_to(explosion_position)
	if distance < explosion_radius:
		take_damage(1)  # Уменьшаем здоровье на 1 сердечко

func update_hearts(new_health: int):
	var hearts_container = get_node("../../CanvasLayer/HeartsContainer")
	$HeartsContainer.update_hearts(new_health)  # Обновляем hearts


