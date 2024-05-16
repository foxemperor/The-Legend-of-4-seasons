extends RigidBody2D

@export var throw_force := 500

var is_held := false
var holding_player: Node # Указываем тип переменной holding_player

func _physics_process(delta):
	if is_held:
		global_position = holding_player.global_position

func pick_up(player: Node): # Указываем тип аргумента player
	is_held = true
	holding_player = player
	freeze = true # Используем freeze вместо mode

func throw(direction: Vector2): # Указываем тип аргумента direction
	is_held = false
	holding_player = null
	freeze = false # Используем freeze вместо mode
	apply_central_impulse(direction * throw_force)
