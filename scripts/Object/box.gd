extends CharacterBody2D

@export var move_speed := 20
@export var contact_duration = 1.0 # Время контакта для перемещения
var player_contact_timer = 0.0
var is_player_overlapping = false

func _physics_process(delta):
	if is_player_overlapping:
		player_contact_timer += delta
		if player_contact_timer >= contact_duration:
			var direction = get_node("/root/Player").global_position - global_position
			direction = direction.normalized()
			velocity = direction * move_speed
			move_and_slide()
	else:
		player_contact_timer = 0.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		is_player_overlapping = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		is_player_overlapping = false
